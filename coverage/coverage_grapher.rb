#!/usr/bin/env ruby


coverage_file_prefix = ARGV[0]

coverage_files = Dir.glob(coverage_file_prefix + "*")

puts "found #{coverage_files.size} files matching #{coverage_file_prefix}"

coverage_files.each do |coverage_file|
  filename = File.basename(coverage_file)
  filename_components = filename.split(".")
  chr = filename_components[-2]
  puts filename
  command = "R --no-save --quiet --args #{coverage_file} #{filename} < coverage_grapher.R"
  puts command
  system(command)
end
