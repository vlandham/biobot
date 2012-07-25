#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sample_report'

class FastqcReader
  attr_reader :dir, :alt_names, :data

  def initialize fastqc_dir, sample_sheet_file = nil
    @alt_names = {}

    if !File.directory?(fastqc_dir)
      puts "ERROR: not a directory"
      raise "not fastqc directory"
    end

    if sample_sheet_file
      if File.exists?(sample_sheet_file)
        @alt_names = get_alt_names(sample_sheet_file)
      else
        puts "ERROR: SampleSheet not found at:#{sample_sheet_file}."
      end
    end

    @data = get_fastqcs_data(fastqc_dir)
  end

  def get_alt_names(filename)
    sample_report = SampleReport.new(filename)
    names = {}
    sample_report.samples.each do |sample|
      filename = File.basename(sample["output"], ".fastq.gz")
      new_name = sample["sample name"]
      names[filename] = new_name
    end
    names
  end

  def alt_name_for name
    if @alt_names[name]
      @alt_names[name]
    else
      name
    end
  end

  def get_fastqcs_data(dirname)
    fastqc_data_files = Dir.glob(File.join(dirname, "*_fastqc", "fastqc_data.txt"))
    # puts "Found: #{fastqc_data_files.size} fastqc directories"

    data = {}

    fastqc_data_files.each do |data_file|
      fastqc_data = get_fastqc_report(data_file)
      name = File.dirname(data_file).split("/")[-1].gsub("_fastqc","")
      name = alt_name_for name
      data[name] = fastqc_data
    end

    data
  end

  def get_fastqc_report(filename)
    data = {}

    lines = File.open(filename,'r').readlines
    modules = split_modules(lines)

    modules.each do |key, mod_lines|
      data[key] = parse_module(mod_lines, key)
    end

    data
  end

  def parse_module lines, name
    # DAMNIT why ?
    # just one occurance where they use two "#" lines
    # in a row...
    if name == "Sequence Duplication Levels"
      lines.shift
    end
    mod_data = []

    if lines.size > 0
      header = lines.shift.chomp.split("\t")
      header[0] = header[0][1..-1]
      lines.each do |line|
        line_hash = Hash[header.zip(line.chomp.split("\t"))]
        mod_data << line_hash
      end
    end
    mod_data
  end

  def split_modules(lines)
    modules = {}
    cur_module = nil
    lines.each do |line|
      if line[0..1] == ">>"
        if line.chomp == ">>END_MODULE"
        else
          cur_module = line.chomp.split("\t")[0].gsub(">>","")
          modules[cur_module] = Array.new
        end
      else
        if cur_module
          modules[cur_module] << line
        end
      end
    end
    modules
  end
end

# fastqc_reader = FastqcReader.new(ARGV[0],ARGV[1])
# 
# puts fastqc_reader.data.inspect


