#!/usr/bin/env ruby

require 'parallel'

CUR_DIR = File.expand_path(File.dirname(__FILE__))
$:.unshift(CUR_DIR)

require 'sample_report'

fastq_dir = File.expand_path(ARGV[0])
output_dir = File.join(File.dirname(fastq_dir), "align")

PIPETTE = File.join("/n", "projects", "jfv", "pipette", "pe_bwa.rb")
CONFIG_FILE = File.join(CUR_DIR, "pe_bwa_config.yml")

samplereport_filename = File.join(fastq_dir, "Sample_Report.csv")

if !File.exists?(samplereport_filename)
  puts "ERROR: need Sample_Report.csv"
  exit(1)
end

# reject second read as they will be handled below
sequence_filenames = Dir.glob(File.join(fastq_dir, "s_*_1_*.trim.fastq.gz"))
sequence_filenames.reject! {|name| name =~ /Undetermined/}

puts "Found #{sequence_filenames.size} sequences"

report = SampleReport.new(samplereport_filename)

Parallel.each(sequence_filenames, :in_processes => 5) do |sequence_filename|
  sequence_basename = File.basename(sequence_filename)
  puts sequence_basename
  original_name = sequence_basename.gsub(".trim","")
  sequence_data = report.data_for original_name

  name = sequence_data["sample name"]
  name = name.downcase.gsub(" ", "")
  input = sequence_filename
  #TODO fix badness
  pair = sequence_filename.split("_")[0..-3].join("_") + "_2_" + sequence_filename.split("_")[-1]

  output = File.join(output_dir, "sample_#{name}", "sample_#{name}")

  # puts name
  # puts input
  # puts pair

  command = "#{PIPETTE} -y #{CONFIG_FILE} --input #{input} --pair #{pair} --output #{output} --name #{name}"
  puts command
  result = %x[#{command}]
  puts result
end


