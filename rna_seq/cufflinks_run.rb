#!/usr/bin/env ruby

start_path_filename = ARGV[0]

def execute command
  puts command
  system(command)
end

REFERENCE = "/n/data1/genomes/bowtie-index/mm9/mm9.fa"
GTF = "/n/data1/genomes/bowtie-index/mm9/Ens_63/mm9.Ens_63.gtf"

CUFFLINKS_BIN = "/n/site/inst/Linux-x86_64/bioinfo/cufflinks/cufflinks-1.0.3.Linux_x86_64/cufflinks"

bam_files = Dir.glob(File.join(start_path_filename, "*.bam"))

bam_files.each do |bam_file|
  bam_file = File.expand_path(bam_file)
  path = File.expand_path(File.dirname(bam_file))
  bam_name = File.basename(bam_file)
  bam_file_fields = bam_name.split(".")

  folder_name = bam_file_fields[0..-2].join('.') + "_cufflinks"

  cufflinks_dir = File.expand_path(File.join(path,  folder_name))

  command = "mkdir -p #{cufflinks_dir}"
  execute command

  command = "#{CUFFLINKS_BIN} -p 4 -o #{cufflinks_dir} -G #{GTF} #{bam_file}"
  execute command


end
