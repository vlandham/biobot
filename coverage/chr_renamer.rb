#!/usr/bin/env ruby

require 'fileutils'
require 'tempfile'

coverage_file_prefix = ARGV[0]

coverage_files = Dir.glob(coverage_file_prefix + "*")

puts "found #{coverage_files.size} files matching #{coverage_file_prefix}"
fix_dir = "./mm9.exons.fix"
FileUtils.mkdir_p(fix_dir)

coverage_files.each do |coverage_file|
  filebase = File.basename(coverage_file)
  t_file = Tempfile.new("#{filebase}.tmp", "/tmp")
  File.open(coverage_file, 'r') do |file|
    file.each_line do |line|
      t_file.puts line.gsub(/^chr/,"")
    end
  end
  t_file.close
FileUtils.mv(t_file.path, File.join(fix_dir, filebase))
end

