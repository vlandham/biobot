#!/usr/bin/env ruby


input_filename = ARGV[0]
MAX_COUNT = 100

output_filename = File.join(File.dirname(input_filename), File.basename(input_filename, File.extname(input_filename)) + "_top_#{MAX_COUNT}.fa")

contig_sizes = Hash.new(0)
File.open(input_filename, 'r') do |file|
  current_contig = nil
  file.each_line do |line|
    if line[0..0] == ">"
      current_contig = line.chomp
      contig_sizes[current_contig] = 0
    else
      line_length = line.chomp.length
      contig_sizes[current_contig] += line_length
    end
  end
end

max_contigs = contig_sizes.sort_by {|k,v| v}.reverse[0...MAX_COUNT]

max_contigs.each do |name,size|
  puts "#{name}: #{size}"
end

max_contig_names = max_contigs.map {|a| a[0]}

output_file = File.open(output_filename, 'w')

File.open(input_filename, 'r') do |file|
  current_contig = nil
  file.each_line do |line|
    if line[0..0] == ">"
      current_contig = line.chomp
    end
    if max_contig_names.include?(current_contig)
      output_file.puts line.chomp
    end
  end
end

output_file.close
