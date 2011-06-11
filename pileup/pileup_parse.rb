#!/usr/bin/env ruby

# Takes mpileup output from std in and converts it to 
# parsable output.
# Outputs to std out.
# Meant to be part of pipe chain. Something like:
# samtools mpileup -f reference.fa sequence.bam | pileup_parse.rb > output
#

ALPHABET = ['A', 'T', 'C', 'G']

def strip_indels read_bases
  stripped_read_bases = read_bases
  while match = stripped_read_bases.match(/(\+|\-)([0-9]+)/)
    num_bases = match[2].to_i
    stripped_read_bases = match.pre_match.concat match.post_match[num_bases..-1]
  end
  stripped_read_bases
end

def count_bases ref_base, read_bases
  read_bases.upcase!
  read_bases = strip_indels read_bases
  base_counts = []
  ALPHABET.each do |letter|
    counts = (letter == ref_base) ? (read_bases.count(",") + read_bases.count(".")) : read_bases.count(letter)
    base_counts << counts
  end
  base_counts
end

def print_out fields, base_counts
  base_outs = base_counts.join("\t")
  output = fields[0..3].join("\t")
  puts "#{output}\t#{base_outs}"
end

ARGF.each do |line|
  next if line.chomp.empty?
  fields = line.split(" ")
  base_counts = count_bases fields[2], fields[4]
  print_out fields, base_counts
end
