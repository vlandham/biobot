#!/usr/bin/env ruby

starting_dir = ARGV[0]

fpkm_files = Dir.glob(File.join(starting_dir, "**", "**", "genes.fpkm_tracking"))

puts "#{fpkm_files.size} files found"

output_dir = File.join(starting_dir, "fpkms")

system("mkdir -p #{output_dir}")


fpkm_files.each do |fpkm_file|
  new_name = File.dirname(fpkm_file).split("/")[-3]
  new_filename = File.join(output_dir, new_name + ".genes.fpkm_tracking")
  command = "mv #{fpkm_file} #{new_filename}"
  puts command
  system command
end
