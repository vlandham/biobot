#!/usr/bin/env ruby

line_count = 0
heads = Hash.new(0)
ARGF.each do |line|
  if line_count == 1
	head = line[0..5]
	heads[head] += 1
  end
  line_count = (line_count + 1) % 4
end

sorted_heads = heads.to_a.sort {|x,y| y[1] <=> x[1]}
(0..20).each do |index|
	puts "#{sorted_heads[index][0]}, #{sorted_heads[index][1]}" unless index >= sorted_heads.size
end

