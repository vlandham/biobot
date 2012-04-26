#!/usr/bin/env ruby

snps_1_filename = ARGV[0]
snps_2_filename = ARGV[1]


if !snps_1_filename or !snps_2_filename
  puts "ERROR: need two annotated snp files"
  raise "invalid inputs"
end

output_name = snps_1_filename.split(".")[0..-2].join(".") + ".unique.txt"

def parse_snpeff_file filename
  contents = File.open(filename, 'r').read.split("\n")
  header = contents.shift.split("\t")
  data = contents.collect {|line| Hash[header.zip(line.split("\t"))]}
  data
end

def same_snp snp_1, snp_2
  same = true
  ["# Chromo", "Position", "Change", "Change type"].each do |field|
    if snp_1[field] != snp_2[field]
      same = false
      return same
    end
  end
  same
end

snps_1 = parse_snpeff_file snps_1_filename
snps_2 = parse_snpeff_file snps_2_filename

puts "excluding variants in #{snps_1_filename} that are found in #{snps_2_filename}"

output = File.open(output_name, 'w')
output.puts(snps_1.first.keys.join("\t"))

snps_1.each do |snp|
  keep = true
  snps_2.each do |snp2|
    if same_snp(snp,snp2)
      keep = false
      break
    end
  end

  if keep
    output.puts(snp.values.join("\t"))
  end
end

output.close


