#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require 'optparse'
require 'fileutils'
require 'pipeline'

options = {}
options[:root_outsource_dir] = "/qcdata/Outsource/"
options[:ftp_server] = "genomics.med.tufts.edu"
options[:ftp_user] = "agp"
options[:ftp_password] = "Stowers09"
options[:outsource_dir] = File.join(options[:root_outsource_dir], options[:ftp_server])
options[:skip_extract] = false
options[:skip_ftp] = false

OptionParser.new do |o|
  o.on('-f', '--flowcell FLOWCELL_ID', 'REQUIRED: flowcell id') {|b| options[:flowcell] = b}
  o.on('-d', '--download_dir DOWNLOAD_DIR', 'REQUIRED: download directory from tufts') {|b| options[:download_dir] = b}
  o.on('-s', '--skip_extract', 'Skips extraction and move step') {|b| options[:skip_extract] = b}
  o.on('-w', '--skip_ftp', 'Skips ftp download step') {|b| options[:skip_ftp] = b}
  o.on('-n', '--name NAMES_FILE', 'Provide the path to a names.txt file for name extraction') {|b| options[:name] = b}
  o.on('-y', '--yaml YAML_FILE', String, 'Yaml configuration file that can be used to load options. Command line options will trump yaml options') do |b|
    options.merge!(Hash[YAML::load(open(b)).map {|k,v| [k.to_sym, v]}])
  end
  o.parse!
end

raise "ERROR: no Flowcell ID provided" unless options[:flowcell]
raise "ERROR: no Download Directory provided" unless options[:download_dir]

download_dir = options[:download_dir]
flowcell_id = options[:flowcell]

names_file = options[:name] ? File.expand_path(options[:name]) : nil
if names_file
  raise "ERROR: Invalid names file at: #{names_file}" unless File.exists? names_file
else
  puts "WARNING: no names provided. Fastqc samples might be incorrect."
end

# move folder
local_download_dir = download_dir + "_" + flowcell_id
new_local_dir = File.join(options[:outsource_dir], local_download_dir)
unless Dir.exists? new_local_dir
  system("mv #{local_dir} #{new_local_dir}")
end

Dir.chdir new_local_dir

unless options[:skip_extract]
  puts "extracting"
  # md5sum
  Dir.iterate_over("**/*md5*") {|path, file| system("md5sum -c #{file}")}

  # untar
  Dir.iterate_over("**/*sequence.tgz") {|path, file| system("tar -xvf #{file}")}
else
  puts "skipping extraction"
end

analysis_dir = new_local_dir
FileUtils.mkdir_p analysis_dir unless Dir.exists? analysis_dir

new_old_name = {}
Dir.iterate_over("**/*sequence.txt") do |path, file|
  old_name = File.join(path,file)
  cell_name = path.split("/")[-1]
  new_name = "#{cell_name}_#{file}"
  puts "moving #{old_name} to #{new_name}"
  new_old_name[new_name] = old_name
  new_path = File.join(analysis_dir, new_name)
  system("mv #{file} #{new_path}")
end

begin
  # now we should have all the sequence files in one directory...
  names_file_option = ""
  if names_file
    FileUtils.move names_file, analysis_dir, :force => true
    names_file_option = "--name #{File.basename(names_file)}"
  end

  Dir.chdir analysis_dir
  fastqc_script = "#{File.join(SCRIPT_PATH, "fastqc.pl")} -v #{names_file_option}"
  puts "running: #{fastqc_script}"
  system(fastqc_script)

ensure
  #move them back
  new_old_name.each do |new_name, old_name|
    if File.exists?(new_name)
      puts "moving #{new_name} to #{old_name}"
      system("mv #{new_name} #{old_name}")
    else
      puts "ERROR: file not found: #{new_name}"
    end
  end
end

def deploy flowcell_id, root_dir
  Dir.chdir root_dir

  # lets try to deploy files
  command = "#{SCRIPT_PATH}/ngsquery.pl fc_file_dirs #{flowcell_id}"
  results = %x[#{command}]
  dirs = results.split("\n").map {|line| line.split("\t")[-2]}

  if dirs.size == 1
    # we only have to deal with one export dir, but we can
    # try to formulate this as if it would work for multiple dirs
    dirs.each do |export_dir|
      FileUtils.mkdir_p export_dir unless Dir.exists? export_dir
      Dir.iterate_over("**/*sequence.txt") do |path, file|
        cell_name = path.split("/")[-1]
        new_path = File.join(export_dir, cell_name)
        puts "copying #{file} to #{new_path}"
        FileUtils.mkdir_p new_path unless Dir.exists? new_path
        FileUtils.cp file, new_path
      end

      # ugly - but what can you do
      Dir.iterate_over("*/*/*/Summary.???") do |path, file|
        cell_name = path.split("/")[-2]
        new_path = File.join(export_dir, cell_name)
        FileUtils.mkdir_p new_path unless Dir.exists? new_path
        puts "copying #{file} to #{new_path}"
        FileUtils.cp file, new_path
      end

      # copy the fastqc
      fastqc_dir = File.join(analysis_dir, "fastqc")
      puts "copying #{fastqc_dir} to #{export_dir}"
      FileUtils.cp_r fastqc_dir, export_dir
    end
  else
    puts "WARNING: Number of distribution locations = #{dirs.size}. You are on your own!"
  end
end

deploy flowcell_id, new_local_dir
end
puts "pipeline complete!"
