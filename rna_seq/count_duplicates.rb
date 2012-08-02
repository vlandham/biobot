#!/usr/bin/env ruby

PICARD = "/n/site/inst/Linux-x86_64/bioinfo/stage/picard/current"
JAR = "MarkDuplicates.jar"

JAVA = "java -Xmx2g -jar #{PICARD}/#{JAR}"

starting_dir_name = ARGV[0]
bam_files = Dir.glob(File.expand_path(File.join(starting_dir_name, "**", "*.bam")))

output_dir_name = File.join(starting_dir_name, "dups")

command = "mkdir -p #{output_dir_name}"
system(command)

puts "found #{bam_files.size} bam files"

bam_files.each do |bam_file|
  bam_name = File.basename(bam_file)
  output_filename = File.join(output_dir_name, bam_name)
  metrics_file = File.join(output_dir_name, File.basename(bam_name, File.extname(bam_name)) + "_metrics.txt")

  command = "#{JAVA} INPUT=#{bam_file} OUTPUT=#{output_filename} METRICS_FILE=#{metrics_file}"
  puts command
  system(command)
end



