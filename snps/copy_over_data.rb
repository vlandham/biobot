#!/usr/bin/env ruby

csv_filename = ARGV[0]
data_filename = ARGV[1]


output_filename = csv_filename.split(".")[0..-2].join(".") + ".with_wt.csv"
outputfile = File.new(output_filename, 'w')

raise "ERROR: csv file missing" unless csv_filename
raise "ERROR: data file missing" unless data_filename

csv_lines = File.open(csv_filename, 'r') {|csv_file| csv_file.readlines}
data_lines = File.open(data_filename, 'r') {|data_file| data_file.readlines}

data_header = data_lines.shift.split()

data = data_lines.collect do |line|
  Hash[data_header.zip(line.chomp.split("\t"))]
end

data.delete_if {|d| d["Locus"].nil?}

puts data.inspect

header = csv_lines.shift.chomp.split(",")
header.insert 8, "\"ICS_cov\""
header.insert 9, "\"ICS_base_cov\""
outputfile << header.join(",") << "\n"
csv_lines.each do |line|
  csv_data = line.chomp.split(",")
  csv_id = "#{csv_data[0].gsub(/"/,"")}:#{csv_data[1]}"
  puts csv_id
  data.each do |d|
    if d["Locus"] == csv_id
      csv_data.insert 8, d["Total_Depth"]
      csv_data.insert 9, d["ds_base_counts"]
      outputfile << csv_data.join(",") << "\n"
    end
  end
  
end
