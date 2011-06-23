#!/usr/bin/env ruby

def count_names input_file
  raise "ERROR: #{input_file} not found" unless File.exists? input_file

  name_match = /#(\w+)/
  unique_names = Hash.new(0)
  index = 0
  File.open(input_file, 'r') do |file|
    file.each_line do |line|
      next unless line[0..0] == "@"
      if line =~ name_match
        name = $1
        unique_names[name] += 1
      end
      if index % 100000 == 0
        #puts "unique names: #{unique_names.size}"
      end
      index += 1
    end
  end
  unique_names.to_a.sort {|x,y| y[1] <=> x[1]}
end

# The magic if clause that lets the same file serve as a library or a script
if __FILE__ == $0
  raise "ERROR: input sequence file required" unless ARGV[0]
  names = count_names ARGV[0]
  names.each do |name, count|
    puts "#{name}\t#{count}"
  end
end

