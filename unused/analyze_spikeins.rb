#!/usr/bin/env ruby

# input: sam file generated from sequence file being aligned to a fasta file where the fasta file only contains spikein sequences
# What we want is some measurement of how many sequences were aligned to each spikein
#
# Originally designed for looking at RNA-seq data (which shouldn't matter)
# The alignment was performed with bowtie. Something like:
# bowtie -S -p 8 spikeins/ERCC92 s_1_1_sequence.txt spikeins/s_1_1.sam
# Prior to running this, bowtie-build was run to create index files of the spikein fasta file
# bowtie-build spikeins/ERCC92.fa ERCC92
#
# So the input to this script would be the s_1_1.sam file generated from the bowtie alignment
#


input_filename = ARGV[0]

raise "ERROR: required input: aligned sam file" unless input_filename
raise "ERROR: #{input_filename} not found or not valid" unless File.exists? input_filename
raise "ERROR: #{input_filename} is not a .sam file" unless input_filename.split(".")[-1] == "sam"

basename = input_filename.split(".")[0..-2].join(".") 
results_output_filename = basename + ".sequence_counts.txt"
output_filename = basename + ".valid.sam"

class String
  def is_sequence_header?
    self[0..2] == "@SQ"
  end

  def is_header?
    self[0] == "@"
  end
end

class Sequence
  include Comparable
  attr_accessor :name, :length

  def initialize(name, length)
    @name = name
    @length = length
  end

  def self.from_line line
    line =~ /SN:(\S+)\s*LN:(\d*)/
    Sequence.new $1, $2.to_i
  end

  def <=>(rhs)
    self.name <=> rhs.name
  end
end

class SAMAnalyzer
  def initialize(options)
    @input_filename = options[:input]
    @results_output_filename = options[:results_output]
    @output_filename = options[:output]
    @sequences = Hash.new
    @sequences["*"] = 0
  end

  def run
    self.count @output_filename
    self.output @sequences, @results_output_filename
  end

  def output sequences, output_filename
    output_file = File.new(output_filename, 'w')
    sorted_sequences = sequences.to_a.sort {|x,y| y[1] <=> x[1]}
    total = sorted_sequences.inject(0) {|sum,seq| sum += seq[1]; sum}
    found_total = total - sequences["*"]
    sorted_sequences << ["total_found", found_total]

    output_file << "name\tcount\ttotal%" << "\n"
    sorted_sequences.each do |name, count|
      total_percent = (count.to_f / total.to_f).round(4)
      output_file << "#{name}\t#{count}\t#{total_percent}" << "\n"
    end

    output_file.close
  end

  def count output_filename
    output_file = File.new(output_filename, 'w')
    line_count = 0
    check_for_header = true
    File.open(@input_filename, 'r') do |file|
      file.lines do |line|
        if check_for_header and line.is_sequence_header?
          @sequences[Sequence.from_line(line).name] = 0
          output_file << line
        elsif check_for_header and line.is_header?
          output_file << line
          next
        else
          check_for_header = false
          alignment = line.split("\t")[2]
          @sequences[alignment] += 1
          if alignment != "*"
            output_file << line
          end
        end
        puts "line #{line_count}" if line_count % 1000000 == 0
        line_count += 1
      end
    end
    output_file.close
  end
end

start_time = Time.now
options = {:input => input_filename,
           :results_output => results_output_filename,
           :output => output_filename}
SAMAnalyzer.new(options).run
end_time = Time.now

puts "output to: #{output_filename}"
puts "results to: #{results_output_filename}"
puts "time: #{(end_time - start_time)} seconds"
