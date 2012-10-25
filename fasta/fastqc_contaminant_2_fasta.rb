#!/usr/bin/env ruby

intput_filename = ARGV[0]

output_filename = intput_filename.split(".")[0..-2].join(".") + ".fa"


data = File.read(intput_filename).split("\n").delete_if {|l| l =~ /^#/ or l.strip.empty?}

output = ""

data.each do |l|
  fields = l.squeeze("\t").split("\t").collect {|f| f.strip}
  output += ">#{fields[0]}\n"
  output += "#{fields[1]}\n"
end

File.open(output_filename, 'w') do |file|
  file << output
end
