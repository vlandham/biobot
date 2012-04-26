#!/usr/bin/env ruby

# tries to convert fastq file with casava 1.8 names to 1.7 names.
# only tested on uncompressed fastq file with paired-end reads
#
# CASAVA 1.8 name
# @instrument_name:run_ID:flowcell_ID:lane:tile:x_pos:y_pos read_number:is_filtered:control:barcode
#
# CASAVA 1.7 name
# @instrument_name:lane:tile:x_pos:y_pos#barcode/read


fastq_filename = ARGV[0]

if !fastq_filename
  puts "ERROR: need fastq filename"
  puts "usage: casava_18_2_17_names_converter.rb sequence.fastq"
  exit(1)
end

output_filename = File.basename(fastq_filename).split(".")[0..-2].join(".") + ".17_names" + ".fastq"

output_file = File.open(output_filename,'w')


File.open(fastq_filename, 'r') do |file|
index = 0
file.each_line do |line|
  if index % 4 == 0
    fields = line.chomp.split(" ").collect {|f| f.split(":")}.flatten
    new_name = fields.values_at(0,3,4,5,6).join(":") + "#" + fields[10] + "/" + fields[7]
    output_file.puts new_name
  else
    output_file.puts line
  end
  index += 1
end
end



output_file.close


