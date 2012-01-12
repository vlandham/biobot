#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sample_report'

BOWTIE_EBT = "spikeins/ERCC92"
BOWTIE = "bowtie"

starting_dir_name = ARGV[0]
output_dir_name = File.join(File.dirname(__FILE__), "spikein_align")

fastq_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "*.fastq.gz")))
sample_report_file = File.expand_path(File.join(starting_dir_name, "Sample_Report.csv"))
fc_id = File.basename(starting_dir_name)


sample_report = SampleReport.new(sample_report_file)

# reject undetermined
fastq_files.reject! {|ff| ff =~ /Undetermined/}

fastq_files.each do |fastq_file|
  puts fastq_file
  fastq_data = sample_report.data_for(fastq_file)
  #puts fastq_data.inspect

  sample_name = fastq_data["sample name"]

  output_file = File.expand_path(File.join(output_dir_name, fc_id, sample_name + ".sam"))
  puts output_file
  system("mkdir -p #{File.dirname(output_file)}")
  command = "zcat #{fastq_file} | #{BOWTIE} -S -p 8 #{BOWTIE_EBT} - #{output_file}"
  puts command
  system(command)
end
