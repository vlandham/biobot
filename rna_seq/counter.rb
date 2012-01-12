#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

COUNT_SEQ = "./count_sequences.rb"
COUNT_MULTI = "./count_multis.rb"

require 'sample_report'

starting_dir_name = ARGV[0]
bam_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "**", "*.bam")))


fc_id = File.basename(starting_dir_name)


bam_files.each do |bam_file|
  output_dir_name = File.dirname(bam_file)

  count_output = File.join(output_dir_name, "counts.txt")
  multi_output = File.join(output_dir_name, "multis.txt")

  command = "samtools view #{bam_file} | #{COUNT_SEQ} > #{count_output}"
  puts command
  system(command)

  command = "#{COUNT_MULTI} #{count_output} > #{multi_output}"
  puts command
  system(command)

end
