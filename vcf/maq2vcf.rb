#!/usr/bin/env ruby

# convert maq view/snp format to
# vcf format
#

maq_filename = ARGV[0]

vcf_filename = File.basename(maq_filename).split(".")[0..-2].join(".") + ".vcf"

def header
  content = "##fileformat=VCFv4.1\n"
  content += "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth\">\n"
  content += "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n"
  content
end

VIEW_HEADERS = %w(chr loc ref con qual depth avg_hits hi_qual min_qual sec log_like third)

def line_to_hash line
  Hash[VIEW_HEADERS.zip(line.chomp.split("\t"))]
end

def view_to_vcf hash
  alt = hash["con"]
  if hash["con"] == hash["ref"]
    alt = "."
  end
  new_data = [hash["chr"], hash["loc"], ".", hash["ref"],
              alt, hash["qual"], "PASS",
              "DP=#{hash["depth"]}"]

  new_data.join("\t")
end

output_file = File.new(vcf_filename,'w')

output_file.print header

File.open(maq_filename, 'r') do |file|
  file.each_line do |line|
    data = line_to_hash line
    output_file.puts view_to_vcf(data)
  end
end

output_file.close
