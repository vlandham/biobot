#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require 'optparse'
require 'yaml'
require 'fileutils'
require 'pipeline'

@valid_steps = [:extract, :move_sequences, :run_fastqc, :distribute_sequences, :distribute_exports, :distribute_summary, :distribute_fastqc]
options = {}
options[:group_outsource_dir] = "gtac"
options[:steps] = @valid_steps 
OptionParser.new do |o|
  o.on('-f', '--flowcell FLOWCELL_ID', 'REQUIRED: flowcell id') {|b| options[:flowcell] = b}
  o.on('-d', '--directory LOCAL_DIR', 'REQUIRED: local directory files are in') {|b| options[:directory] = b}
  o.on('-n', '--name NAMES_FILE', 'Provide the path to a names.txt file for name extraction') {|b| options[:name] = b}
  o.on('-s', "--steps #{@valid_steps.join(",")}", Array, 'Specify only which steps of the pipeline should be executed') {|b| options[:steps] = b.collect {|step| step.to_sym} }
  o.on('-t', '--test', 'Test run - do not perform actual move / copy steps') {|b| options[:test] = b}
  o.on('-y', '--yaml YAML_FILE', String, 'Yaml configuration file that can be used to load options. Command line options will trump yaml options') do |b|
    options.merge!(Hash[YAML::load(open(b)).map {|k,v| [k.to_sym, v]}])
  end
  o.parse!
end

raise "ERROR: no Flowcell ID provided" unless options[:flowcell]
raise "ERROR: no directory provided. use -d flag" unless options[:directory]

options[:directory] = File.expand_path options[:directory]
raise "ERROR: directory not found:#{options[:directory]}." unless Dir.exists? options[:directory]

options[:full_local_analysis_dir] = File.join(options[:directory], "analysis")

flowcell_id = options[:flowcell]

@test = options[:test]
# check our steps
# TODO: good canidate for functionality common to all pipelines
if !options[:steps] || options[:steps].empty?
  raise "ERROR no steps provided"
end

@steps = options[:steps].collect {|step| step.to_sym}

@steps.each do |step|
  unless @valid_steps.include? step
    raise "ERROR: #{step} not a valid step.\nvalid steps: #{@valid_steps.inspect}"
  end
end

puts "performing steps: #{@steps}"
puts "IN TEST MODE" if @test


@samples_data = SamplesData.for_flowcell(flowcell_id, options[:directory])

@new_files = {}

# TODO: organize these functions into classes so we don't
# have a bunch of free floating functions to duplicate

def execute command
  puts command
  system(command) unless @test
end

def performing_step? step
  @steps.include? step.to_sym
end

def extract_sequence_files
  if performing_step? :extract
    puts "extracting"
    # md5sum
    Dir.iterate_over("**/*md5*") {|path, file| system("md5sum -c #{file}")}

    # untar
    Dir.iterate_over("**/*sequence.tgz") {|path, file| system("tar -xvf #{file}")}
  else
    puts "skipping extraction"
  end
end

def all_distribution_directories
	dist_dirs = @samples_data.collect {|sd| sd["DistDir"]}
	dist_dirs.uniq.compact
end

def add_file_to_distribute current_path, distribution_dir
	if @new_files.include? current_path
		puts "ERROR: already have #{current_path}"
		raise "ERROR: already present"
	end
	@new_files[current_path] = distribution_dir
end

def distribute_summaries options
  Dir.chdir options[:directory]

  distribution_directories = all_distribution_directories

  summaries = []
  distribution_directories.each do |dist_dir|
    Dir.iterate_over("**/Summary.???") do |path, file|
      dir_num = get_sample_directory_number path
      path =~ /GERALD_((\d+-?)+)/
      gerald_date = $1
      sample_matches = @samples_data.select {|data| data["Directory"] == dir_num && data["DistDir"] == dist_dir}

      if !gerald_date
        puts "WARNING: #{path}/#{file} not in Gerald directory. Skipping"
        next
      end

      if sample_matches.size >= 1
        file_parts = file.split(".")
        new_file_additions = dir_num + "_" + gerald_date
        new_file_name = file_parts[0] + "_" + new_file_additions +  "." + file_parts[-1]
        new_full_path = File.join(dist_dir, new_file_name)
        if summaries.include? new_full_path
          puts "ERROR: already have a #{new_full_path}"
          raise "ERROR summary already present"
        end
        execute("cp #{file} #{new_full_path}")
        summaries << new_full_path
      else
        puts "WARNING: #{dir_num} not in #{dist_dir} skipping"
      end
    end
  end
end

def distribute_fastqc options
  distribution_directories = all_distribution_directories

  distribution_directories.each do |dist_dir|
    fastqc_dir = File.join(options[:full_local_analysis_dir], "fastqc")
    if File.exists? fastqc_dir
      execute("cp -r #{fastqc_dir} #{dist_dir}")
    else
      puts "WARNING: no fastqc folder found. skipping"
    end
  end
end

def distribute_new_files options
  distribution_directories = all_distribution_directories

  distribution_directories.each do |dist_dir|
    execute("mkdir -p #{dist_dir}") unless Dir.exists? dist_dir
  end

  Dir.chdir options[:full_local_analysis_dir]

  @new_files.each do |file, dist_dir|
    execute("cp #{file} #{dist_dir}")
  end
end

def get_sample_directory_number path
  # add / to end of path in case the
  # sample directory # is last component
  # of directory structure. I don't know of a
  # better way to match just the 001 002 003...
  # directory names. Not a very good naming system,
  # if you ask me...
  path += "/"
  directory_number_match = /\/(\d{3})\//
  path =~ directory_number_match
  $1
end

def get_sample_lane_number file
  lane_number = 0
  correct_file_format = /^s_(\d)_/
  crazy_tufts_file_format = /^(\d)\./

  if file =~ correct_file_format
    lane_number = $1
  elsif file =~ crazy_tufts_file_format
    puts "WARNING: non-standard sequence file name found: #{file}"
    lane_number = $1
  else
    raise "ERROR: file does not match known naming convention. Another awesome naming convention?"
  end
  lane_number
end

def new_name_for_file filename, sample_data
  file_parts = filename.split("_")
  new_file_additions = sample_data["SampleID"] + "_" + sample_data["Index"]
  new_file_name = file_parts[0..1].join('_') + "_" + new_file_additions +  "_" + file_parts[2..-1].join('_')
  new_file_name
end

def get_sample_data_for path, file
  sample_dir = get_sample_directory_number(path)
  sample_lane = get_sample_lane_number(file)

  sample_matches = @samples_data.select {|data| data["Directory"] == sample_dir && data["Lane"] == sample_lane}

  raise "ERROR: no match found for #{path}/#{file} : dir#:#{sample_dir}. lane#:#{sample_lane}." if sample_matches.size == 0
  raise "ERROR: more than one match found in SamplesDirectories.csv for #{path}/#{file}" unless sample_matches.size == 1
  sample_data = sample_matches.shift
  sample_data
end

# ---------------
# MAIN PROGRAM --
# ---------------

Dir.chdir options[:directory]
FileUtils.mkdir_p options[:full_local_analysis_dir] unless Dir.exists? options[:full_local_analysis_dir]

need_to_rename_sequence_files = true

analysis_files = Dir.glob(options[:full_local_analysis_dir]+"/*")

if analysis_files.size != 0
  need_to_rename_sequence_files = false
end

if need_to_rename_sequence_files
  Dir.iterate_over("**/*sequence.txt") do |path, file|

    sample_data = get_sample_data_for(path, file)

    new_file_name = new_name_for_file file, sample_data
    new_file_full_path = File.join(options[:full_local_analysis_dir], new_file_name)
    if performing_step? :move_sequences
      command = "mv #{file} #{new_file_full_path}"
      execute command
    end

    sample_distribution_dir = sample_data["DistDir"]

    raise "ERROR: no distribution dir found for #{path}/#{file}" unless sample_distribution_dir

    if performing_step? :distribute_sequences
      add_file_to_distribute new_file_full_path, sample_distribution_dir
    end
  end
else
  puts "Skipping the renaming of the sequence files"
end

Dir.iterate_over("**/*{export,eland}.{txt,tgz}") do |path, file|
  sample_data = get_sample_data_for(path,file)
  new_file_name  = new_name_for_file file, sample_data
  sample_distribution_dir = sample_data["DistDir"]
  raise "ERROR: no distribution dir found for #{path}/#{file}" unless sample_distribution_dir
  full_path = File.join(path,file)
  new_file_full_path = File.join(sample_distribution_dir, new_file_name)

  if performing_step? :distribute_exports
    add_file_to_distribute full_path, new_file_full_path
  end
end

Dir.chdir options[:full_local_analysis_dir]

if !need_to_rename_sequence_files
  Dir.iterate_over("*sequence*") do |path, file|
    file =~ /s_(\d+)_sequence_(\S+)_(\S+)\.txt/
    sample_id = $2
    sample_matches = @samples_data.select {|data| data["SampleID"] == sample_id}
    if sample_matches.size != 1
      raise "ERROR: sample matches # #{sample_matches.size}"
    end
    sample_data = sample_matches.shift
    new_file_full_path = File.join(options[:full_local_analysis_dir], file)
    if performing_step? :distribute_sequences
      add_file_to_distribute new_file_full_path, sample_data["DistDir"]
    end
  end
end

# now we should have all the sequence files in one directory...
# run fastqc
if performing_step? :run_fastqc
  names_file_option = ""
  if options[:name]
    execute("cp -f #{options[:name]} #{options[:full_local_analysis_dir]}")
    names_file_option = "--name #{File.basename(options[:name])}"
  end

  fastqc_script = "#{File.join(SCRIPT_PATH, "fastqc.pl")} -v #{names_file_option}"

  execute fastqc_script
end

distribute_new_files options

if performing_step? :distribute_fastqc
  distribute_fastqc options
end

if performing_step? :distribute_summary
  distribute_summaries options
end

# run summary combiner
command = "#{File.join(SCRIPT_PATH, "combine_summary.rb")} #{flowcell_id}"
execute(command)

# run fc_info
command = "#{File.join(SCRIPT_PATH, "ngsquery.pl")} fc_info_outsource #{flowcell_id}"
fc_info = %x[command]
fc_info_filename = File.new(File.join(options[:directory], "fc_info.txt"), 'w') do |file|
  file << fc_info
end
