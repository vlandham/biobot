#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sample_report'

require 'parallel'

TOPHAT="/n/site/inst/Linux-x86_64/bioinfo/tophat/tophat_1.4.1/tophat"
GTF_FILE="/n/data1/genomes/bowtie-index/mm9/Ens_63/mm9.Ens_63.gtf"
BOWTIE_FILE="/n/data1/genomes/bowtie-index/mm9/mm9"

starting_dir_name = ARGV[0]
output_dir_name = File.join(Dir.pwd, "align")

fastq_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "*.fastq.gz")))
sample_report_file = File.expand_path(File.join(starting_dir_name, "Sample_Report.csv"))
fc_id = File.basename(starting_dir_name)


sample_report = SampleReport.new(sample_report_file)

# reject undetermined
fastq_files.reject! {|ff| ff =~ /Undetermined/}

Parallel.each(fastq_files, :in_processes => 2) do |fastq_file|
  puts fastq_file
  fastq_data = sample_report.data_for(fastq_file)
  puts fastq_data.inspect

  sample_name = fastq_data["sample name"]

  output_folder = File.expand_path(File.join(output_dir_name, fc_id, sample_name, "tophat"))
  puts output_folder
  system("mkdir -p #{output_folder}")
  command = "#{TOPHAT} -G #{GTF_FILE} -p 8 -o #{output_folder} #{BOWTIE_FILE} #{fastq_file}"
  puts command
  system(command)
end
