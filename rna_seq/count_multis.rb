#!/usr/bin/env ruby

filename = ARGV[0]

line_count = 0
total = 0

File.open(filename, 'r') do |file|
  file.each_line do |line|
    line_count += 1
    total += line.split("\t")[1].to_i
  end
end

puts "Number of Lines: #{line_count}"
puts "Totals From Multis: #{total}"
puts "Total Number of Multis: #{total - line_count}"

