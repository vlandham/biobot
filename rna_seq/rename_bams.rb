#!/usr/bin/env ruby


starting_dir = ARGV[0]

bam_files = Dir.glob(File.join(starting_dir, "**", "*.bam"))

puts "#{bam_files.size} bams found"

output_dir = File.join(starting_dir, "all_bams")

system("mkdir -p #{output_dir}")

bam_files.each do |bam_file|
  new_name = File.dirname(bam_file).split("/")[-2]
  new_filename = File.join(output_dir, "#{new_name}.bam")
  command = "mv #{bam_file} #{new_filename}"

  puts command
  system(command)
end
