#!/usr/bin/env ruby

exons_dir = ARGV[0]
bam_file = ARGV[1]
if !exons_dir
  puts "need exons directory"
  raise "no exon directory"
elsif !File.directory?(exons_dir)
  puts "input not a directory"
  raise "not a directory"
end
if !bam_file
  puts "need bam file"
  raise "no bam file"
elsif !File.exists?(bam_file)
  puts "bam file doesn't exist"
  raise "no bam file found"
end

exon_files = Dir.glob(File.join(exons_dir, "*.bed.txt"))
puts "#{exon_files.size} exon files found"

output_prefix = File.basename(bam_file).split(".")[0..-2].join(".")
output_dir = "./chromosome.coverage"
system "mkdir -p #{output_dir}"

exon_files.each do |exon_file|
  # exon filename: mm9.ucsu.exons.chr11.bed.txt
  exon_prefix = File.basename(exon_file).split(".")[0..-3].join(".")
  exon_chromosome = File.basename(exon_prefix).split(".")[-3]

  output_filename = "#{output_prefix}.#{exon_prefix}.coverage"

  output_path = File.join(output_dir, output_filename)
  if File.exists? output_path
    puts "error: #{output_path} already present. overwriting"
  end

  command = "coverageBed -abam #{bam_file} -b #{exon_file} -s -split -d > #{output_path}"
  puts command
  system command
end
