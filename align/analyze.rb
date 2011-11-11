#!/usr/bin/env ruby

# recommended running:
# nohup ./analyze.rb /path/to/input.bam 2>&1 |tee analyze.out.log

input_bam_file = ARGV[0]
cur_dir = File.expand_path(File.dirname(__FILE__))

PIPETTE = File.join("/n", "projects", "jfv", "pipette", "vp.rb")
CONFIG_FILE = File.join(cur_dir, "variant_config.yml")

if !input_bam_file
  puts "ERROR: run using ./analyze.rb [path/to/input.bam]"
  exit(1)
end

input_bam_file = File.expand_path(input_bam_file)
if !File.exists? input_bam_file
  puts "ERROR: bam file not found: #{input_bam_file}"
  exit(1)
end

prefix = File.basename(input_bam_file).split(".")[0]
puts prefix

output = File.join(cur_dir, "analyze", prefix, prefix)

puts "Creating output here:#{output}"

command = "#{PIPETTE} -y #{CONFIG_FILE} --input #{input_bam_file} --output #{output}"
puts command
result = %x[#{command}]
puts result

