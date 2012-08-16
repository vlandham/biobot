#!/usr/bin/env ruby


require 'zlib'

starting_dir = ARGV[0]

fastq_files = Dir.glob(File.join(starting_dir, "**.fastq.gz"))
# fastq_files = [starting_dir]

# puts "#{fastq_files.size} fastq files found"

all_sizes = {}

fastq_files.each do |fastq_file|
  total = 0
  basename = File.basename(fastq_file)
  # puts basename
  line_number = 0
  sample_sizes = Hash.new(0)
  Zlib::GzipReader.open(fastq_file) do |file|
    file.each_line do |line|
      line_number += 1
      if (line_number % 4 != 0) and (line_number % 2 == 0)
        length = line.chomp.length
        sample_sizes[length] += 1
      end

      total += 1
    end
  end
  sample_sizes['total'] = total
  all_sizes[basename] = sample_sizes
end

all_sizes.each do |name, values|
  puts name
  sorted_values = values.sort_by {|size, count| size == 'total' ? 100 : size}
  sorted_values.each do |size, count|
    puts "  #{size}: #{count}"
  end
end
