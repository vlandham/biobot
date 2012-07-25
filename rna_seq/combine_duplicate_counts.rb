#!/usr/bin/env ruby

dup_file_dir_name = ARGV[0]

metric_files = Dir.glob(File.join(dup_file_dir_name, "*_metrics.txt"))

output_file = File.join(dup_file_dir_name, "all_sample_metrics.txt")

data = []
header = nil

metric_files.each do |metric_file|
  name = File.basename(metric_file).gsub("_metric.txt","")
  metrics = []
  lines = File.open(metric_file,'r').readlines
  my_header = nil
  lines.each do |line|
    next if line[0..0] == "#"
    next if line.chomp.strip.empty?
    if !my_header
      my_header = line.chomp.split("\t")
      header ||= my_header
    else
      metrics = line.chomp.split("\t")
      metrics.unshift(name)
    end
    data << metrics
  end
end

File.open(output_file, 'w') do |file|
  file.puts header.join("\t")
  data.each do |d|
    file.puts d.join("\t")
  end
end
