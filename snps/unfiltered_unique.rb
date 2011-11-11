#!/usr/bin/env ruby

def run_filter input_filename
  filter_dir = File.expand_path(File.join(File.dirname(__FILE__), "sample_hjsi3_control")) 
  filter_file = File.join(filter_dir, "sample_hjsi3_control.snps.vcf")

  if input_filename =~ /indel/
    filter_file = File.join(filter_dir, "sample_hjsi3_control.indels.vcf")
  end

  command = "nohup /n/projects/jfv/biobot/snps/filter_matching_vcfs.rb #{input_filename} #{filter_file}"
  command += " 2>&1 > log/#{File.basename(input_filename)}.unique.out.log"

  puts command
  result = system(command)
end

def run_annotate input_filename
  command = "nohup /n/projects/jfv/pipette/bin/annotate_vcf.rb -i #{input_filename} -y ../variant_config.yml 2>&1 > log/#{File.basename(input_filename)}.annotate.out.log"
  result = system(command)
end

unfiltered_snps = Dir.glob(File.join(File.dirname(__FILE__), "**", "*\.{snps,indels}\.vcf"))
unfiltered_snps = unfiltered_snps.reject {|n| n =~ /[cC]ontrol/}
#puts unfiltered_snps

unfiltered_snps.each do |unfiltered_snp|
  puts unfiltered_snp
  unique_name = unfiltered_snp.split(".")[0..-2].join(".") + ".unique.vcf"
  puts unique_name
  run_filter unfiltered_snp
  run_annotate unique_name
end

