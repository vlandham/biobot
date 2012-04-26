#!/usr/bin/env ruby

DIST_PATH = "/n/facility/Bioinformatics/analysis/Mak/Mak-2010-09-26_hym/unfiltered/data/"

unique_files = Dir.glob(File.join(File.dirname(__FILE__), "**", "*\.{snps,indels}\.unique\.*"))

puts unique_files

unique_files.each do |unique_file|
  dir = File.basename(File.dirname(unique_file))

  dist_dir = File.join(DIST_PATH, dir)

  command = "mkdir -p #{dist_dir}"
  puts command
  system(command)

  dist_file = File.join(dist_dir, File.basename(unique_file))

  command = "cp #{unique_file} #{dist_file}"
  puts command
  system(command)
end
