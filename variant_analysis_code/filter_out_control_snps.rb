#!/usr/bin/env ruby
#
# usage filter_out_control_snps.rb control/folder output/folder

control_dir = File.expand_path(ARGV[0])
all_base_dir = File.expand_path(File.dirname(control_dir))

output_dir = ARGV[1]
output_dir ||= File.join(all_base_dir, "unique_out")
output_dir = File.expand_path(output_dir)
command = "mkdir -p #{output_dir}"
system(command)

puts "control dir: #{control_dir}"
puts "all dir: #{all_base_dir}"

FILTERING_SCRIPT = File.join("/n", "projects", "jfv", "pipette", "bin", "fast_filter_matching_vcfs.rb")


control_snps_file = Dir.glob(File.join(control_dir, "*.snps.vcf"))[0]
snp_files_to_filter = Dir.glob(File.join(all_base_dir, "**", "*.snps.vcf"))

if !File.exists? control_snps_file
  puts "ERROR: cannot find snps.vcf file for control"
else
  puts "Using #{File.basename(control_snps_file)} as control for filtering snps"
end

control_indels_file = Dir.glob(File.join(control_dir, "*.indels.vcf"))[0]
indel_files_to_filter = Dir.glob(File.join(all_base_dir, "**", "*.indels.vcf"))

if !File.exists? control_indels_file
  puts "ERROR: cannot find indels.vcf file for control"
else
  puts "Using #{File.basename(control_indels_file)} as control for filtering indels"
end


def filter_variants(mutant_vcf_files, control_vcf_file, output_dir)
  mutant_vcf_files.each do |mutant_file|
    if mutant_file == control_vcf_file
      puts "skipping #{File.basename(mutant_file)}"
    end

    command = "#{FILTERING_SCRIPT} #{mutant_file} #{control_vcf_file} -o #{output_dir}"
    puts command
    system(command)
  end
end

filter_variants(snp_files_to_filter, control_snps_file, output_dir)
filter_variants(indel_files_to_filter, control_indels_file, output_dir)
