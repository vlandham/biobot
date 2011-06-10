#!/usr/bin/env ruby

chromosome = 5
range_start = 83527787
range_end = 91288973
range = (range_start..range_end)

input_filename = ARGV[0]
raise "ERROR no input file" unless input_filename

class String
  def tab_split
    self.chomp.split("\t").collect {|d| d.strip}
  end

  def suffix_with ending
    start = self.split(".")[0..-2].join(".")
    extension = self.split(".")[-1]
    "#{start}#{ending}.#{extension}"
  end
end

class Array
  def annotate_with header
    Hash[header.zip(self)]
  end
end

output_filename = input_filename.suffix_with "_in_range"
output_file = File.new(output_filename, 'w')
genes_file_lines = File.open(input_filename, 'r').readlines

header_line = genes_file_lines.shift
output_file << header_line
header = header_line.tab_split
header = header.collect {|h| h.strip}
genes_file_lines.each do |line|
  data = line.tab_split
  known_data = data.annotate_with header
  known_data["locus"] =~ /^(.*):(.*)-(.*)$/
  gene_chrom, gene_start, gene_end = [$1, $2, $3].collect {|match| match.to_i}
  gene_range = (gene_start..gene_end)
  if (gene_chrom == chromosome) && (range.include?(gene_start))
    output_file << line
  end
end

output_file.close
