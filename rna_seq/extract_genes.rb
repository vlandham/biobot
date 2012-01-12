#!/usr/bin/env ruby


filename = ARGV[0]

genes_filename = filename + ".genes.txt"

genes_file = File.new(genes_filename, 'w')
found_genes = []
File.open(filename, 'r') do |file|
  file.each_line do |line|
    line_items = line.split("\t")
    gene_name = line_items[3].split(":")[0]
    if !found_genes.include? gene_name
      genes_file.puts("#{line_items[0]}\t#{gene_name}")
      found_genes << gene_name
    end
  end
end

genes_file.close
