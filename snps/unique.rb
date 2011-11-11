#!/usr/bin/env ruby

input_filename = ARGV[0]

filter_dir = File.expand_path(File.join(File.dirname(__FILE__), "sample_hjsi3_control")) 
filter_file = File.join(filter_dir, "sample_hjsi3_control.snps.vcf")

if input_filename =~ /indel/
  filter_file = File.join(filter_dir, "sample_hjsi3_control.indels.vcf")
end

command = "nohup /n/projects/jfv/biobot/snps/filter_matching_vcfs.rb #{input_filename} #{filter_file}"
command += " 2>&1 > log/#{File.basename(input_filename)}.unique.out.log"

puts command
result = system(command)
