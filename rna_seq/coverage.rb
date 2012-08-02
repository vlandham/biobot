#!/usr/bin/env ruby
require 'parallel'

starting_dir_name = ARGV[0]

BEDFILE = File.expand_path(File.join(Dir.pwd, "annotations", "mm9.uxons.bed"))

bam_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "*.bam")))

output_dir = File.join(Dir.pwd, "coverage")

system("mkdir -p #{output_dir}")

Parallel.each(bam_files, :in_processes => 4) do |bam_file|

  sample_name = File.basename(bam_file, File.extname(bam_file))
  puts sample_name

  outputfile = File.expand_path(File.join(output_dir, "#{File.basename(BEDFILE)}.#{sample_name}.coverageBed.out.txt"))

  command = "coverageBed -s -split -abam #{bam_file} -b #{BEDFILE} > #{outputfile}"
  puts command
  system command
end
