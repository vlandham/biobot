#!/usr/bin/env ruby
#

vcf_dir = ARGV[0]

vcf_files = Dir.glob(File.join(vcf_dir, "*.vcf"))


ANNOTATE_SCRIPT = File.join("/n", "projects", "jfv", "pipette", "bin", "annotate_vcf.rb")

yaml_file = File.join(File.dirname(__FILE__), "..", "variant_config.yml")
if !File.exists?(yaml_file)
  puts "ERROR: no yaml file found at #{yaml_file}"
  exit(1)
else
  yaml_file = File.expand_path(yaml_file)
end

vcf_files.each do |vcf_file|
  command = "#{ANNOTATE_SCRIPT} -i #{vcf_file} -y #{yaml_file}"
  puts command
  system(command)
end
