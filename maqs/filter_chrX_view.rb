#!/usr/bin/env ruby


view_filename = ARGV[0]

output_filename = File.basename(view_filename).split(".")[0..-2].join(".") + "_chrX.view"

output_file = File.open(output_filename, 'w')

File.open(view_filename, 'r') do |file|
  file.each_line do |line|
    if line[0..3] == "chrX"
      output_file.puts line.chomp
    end
  end
end


output_file.close
