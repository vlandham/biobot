#!/usr/bin/env ruby

filename = ARGV[0]
sample_name = ARGV[1]

output_filename = File.basename(filename).split(".")[0..-2].join(".") + "." + sample_name + ".vcf"
output_file = File.open(output_filename, 'w')

def header
  content = "##fileformat=VCFv4.1\n"
  content += "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth\">\n"
  content += "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n"
  content
end

HOMOZYGOUS_CODES = %w(A C G T)

def homozygous data, index
  HOMOZYGOUS_CODES.include? data[index]
end

def view_to_vcf data
  alt_index = (data[4] != data[3] and homozygous(data,4)) ? 4 : 5



  if data[3] == data[alt_index]
    puts "ERROR: control and mutant match"
    puts data.join("\t")
  end

  new_data = [data[0], data[1], ".", data[3],
              data[alt_index], data[alt_index + 6], "PASS",
              "DP=#{data[alt_index + 3]}"]

  new_data.join("\t")
end

output_file.print(header)
header = []
File.open(filename, 'r') do |file|
  file.each_line do |line|
    data = line.chomp.split("\t")
    if header.empty?
      header = data
    else
      if data[-1] == "both" or data[-1] == sample_name
        output_file.puts view_to_vcf(data)
      end
    end
  end
end


output_file.close

