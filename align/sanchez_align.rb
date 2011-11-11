#!/usr/bin/env ruby

cur_dir = File.expand_path(File.dirname(__FILE__))

PIPETTE = File.join("/n", "projects", "jfv", "pipette", "pe_bwa.rb")
CONFIG_FILE = File.join(cur_dir, "pe_bwa_config.yml")

samplereport_filename = File.join(cur_dir, "Sample_Report.csv")

if !File.exists?(samplereport_filename)
  puts "ERROR: need Sample_Report.csv"
  exit(1)
end

# reject second read as they will be handled below
sequence_filenames = Dir.glob(File.join(cur_dir, "sequences", "s_2_1_ATCACG.fastq.gz"))
sequence_filenames.reject! {|name| name =~ /Undetermined/}

sequence_filenames.reject! {|name| name =~ /Undetermined/}

puts "Found #{sequence_filenames.size} sequences"


class SampleReport
  attr_accessor :samples

  def initialize sample_report_filename
    @samples = parse(sample_report_filename)
  end

  def parse(filename)
    lines = File.readlines(filename)
    header = lines.shift.chomp.split(",")
    samples = []
    lines.each do |line|
      data = line.chomp.split(",")
      samples << Hash[header.zip(data)]
    end
    samples
  end

  def data_for(sequence_filename)
    File.basename(sequence_filename) =~ /s_(\d+)_(\d+)_([ATCG]*)\.fastq.gz/
    @samples.select {|s| s["lane"] == $1 and s["illumina index"] == $3}[0]
  end
end

report = SampleReport.new(samplereport_filename)

sequence_filenames.each do |sequence_filename|
  sequence_data = report.data_for sequence_filename

  name = sequence_data["sample name"]
  name = name.downcase.gsub(" ", "")
  input = sequence_filename
  #TODO fix badness
  pair = sequence_filename.split("_")[0..-3].join("_") + "_2_" + sequence_filename.split("_")[-1]
  output = File.join("align","sample_#{name}", "sample_#{name}")

  puts name
  puts input
  puts pair

  command = "#{PIPETTE} -y #{CONFIG_FILE} --input #{input} --pair #{pair} --output #{output} --name #{name}"
  puts command
  result = %x[#{command}]
  puts result
end


