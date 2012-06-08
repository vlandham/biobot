#!/usr/bin/env ruby
#

require 'parallel'

CUR_DIR = File.expand_path(File.dirname(__FILE__))
$:.unshift(CUR_DIR)

require 'sample_report'

fastq_dir = File.expand_path(ARGV[0])
output_dir = File.join(File.dirname(fastq_dir), "trimmed")

FASTX = File.join("/n", "site", "inst", "Linux-x86_64", "bioinfo", "bin", "fastx_trimmer")
TRIM_FIRST = 1
TRIM_LAST = 90

system("mkdir -p #{output_dir}")

samplereport_filename = File.join(fastq_dir, "Sample_Report.csv")

if !File.exists?(samplereport_filename)
  puts "ERROR: need Sample_Report.csv"
  exit(1)
end

report = SampleReport.new(samplereport_filename)

puts "fastq files in: #{fastq_dir}"

sequence_filenames = Dir.glob(File.join(fastq_dir, "s_*_*_*.fastq.gz"))
sequence_filenames.reject! {|name| name =~ /Undetermined/}

puts "Found #{sequence_filenames.size} sequences"

Parallel.each(sequence_filenames, :in_processes => 6) do |sequence_filename|
  sequence_basename = File.basename(sequence_filename)
  puts sequence_basename
  sequence_data = report.data_for sequence_basename

  output_basename = sequence_basename.split(".")[0..-3].join(".") + ".trim.fastq.gz"

  name = sequence_data["sample name"]
  name = name.downcase.gsub(" ", "")
  output_filename = File.join(output_dir, output_basename)

  puts name

  command = "zcat #{sequence_filename} | #{FASTX} -f #{TRIM_FIRST} -l #{TRIM_LAST} -i - -o #{output_filename} -v -z -Q33"
  puts command

  result = %x[#{command}]
  puts result
end


