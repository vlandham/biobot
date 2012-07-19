#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

COUNT_SEQ = File.join(File.dirname(__FILE__),"count_sequences.rb")
COUNT_MULTI = File.join(File.dirname(__FILE__), "count_multis.rb")

require 'sample_report'

starting_dir_name = ARGV[0]
bam_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "**", "*.bam")))


fc_id = File.basename(starting_dir_name)


bam_files.each do |bam_file|
  output_dir_name = File.dirname(bam_file)

  command = "mkdir -p #{File.join(output_dir_name, "counts")}"
  puts command
  system(command)

  command = "mkdir -p #{File.join(output_dir_name, "multis")}"
  puts command
  system(command)

  name = File.basename(bam_file, File.extname(bam_file))

  count_output = File.join(output_dir_name,"counts", "#{name}_counts.txt")
  multi_output = File.join(output_dir_name, "multis", "#{name}_multis.txt")

  command = "samtools view #{bam_file} | #{COUNT_SEQ} > #{count_output}"
  puts command
  system(command)

  command = "#{COUNT_MULTI} #{count_output} > #{multi_output}"
  puts command
  system(command)

end
