#!/usr/bin/env ruby
#
view_filename = ARGV[0]

output_filename = File.basename(view_filename).split(".")[0..-2].join(".") + "_filter_qual_depth_homo.view"
output_file = File.open(output_filename, 'w')

VIEW_HEADERS = %w(chr loc ref con qual depth avg_hits hi_qual min_qual sec log_like third)

HOMOZYGOUS_CODES = %w(A C G T)

def line_to_hash line
  Hash[VIEW_HEADERS.zip(line.chomp.split("\t"))]
end

def good_quality data
  data['qual'].to_i > 22
end

def good_depth data
  data['depth'].to_i > 4
end

def homozygous data
  HOMOZYGOUS_CODES.include? data['con']
end

File.open(view_filename, 'r') do |file|
  file.each_line do |line|
    data = line_to_hash line

    if good_quality(data) and good_depth(data) and homozygous(data)
      output_file.puts line.chomp
    end

  end
end


output_file.close
