#!/usr/bin/env ruby

class SAMAnalyzer
  def initialize
    @sequence_counts = Hash.new(0)
  end

  def add_to_counts line
    sequence = line.split("\t")[0]
    @sequence_counts[sequence] += 1
  end

  def duplicate_counts
    # paired end reads have the same name? 
    # so we need to look for > 2 ?
    @sequence_counts.select! {|key,value| value > 2}
    count_array = @sequence_counts.to_a.sort! {|x,y| y[1] <=> x[1]}
    count_array
  end
end

if __FILE__ == $0
  samy = SAMAnalyzer.new
  start_time = Time.now
  ARGF.each do |line|
    samy.add_to_counts line
  end
  dups = samy.duplicate_counts
  dups.each do |name, number|
    puts "#{name}\t#{number}"
  end
  end_time = Time.now
  puts "time: #{(end_time - start_time)}"
end
