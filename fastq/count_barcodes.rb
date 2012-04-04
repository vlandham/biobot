#!/usr/bin/env ruby

# Generates counts and ratios of all barcodes found in a fastq file.
# Run Example:
#
# zcat s_1_1_Undetermined.fastq.gz | ./count_barcodes.rb > s_1_1_counts.txt
#
#

class FASTQAnalyzer
  def initialize
    @counts = Hash.new(0)
  end

  def add_to_counts line
    if line[0..3] == "@ILL"
      sections = line.split(":")
      barcode = sections[-1].chomp
      @counts[barcode] += 1
    end
  end

  def output
    puts "counts:"
    total = 0
    sorted_counts = @counts.sort {|a,b| b[1] <=> a[1]}
    sorted_counts.each do |k,v|
      puts "#{k} : #{v}"
      total += v
    end
    puts "total : #{total}"
    puts "\nratios:"
    sorted_counts.each do |k,v|
      puts"#{k} : #{v.to_f / total.to_f}"
    end
  end
end

if __FILE__ == $0
  famy = FASTQAnalyzer.new
  start_time = Time.now
  ARGF.each do |line|
    famy.add_to_counts line
  end

  famy.output
  end_time = Time.now
  puts "time: #{(end_time - start_time)}"
end

