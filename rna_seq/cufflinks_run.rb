#!/usr/bin/env ruby

require 'parallel'

$LOAD_PATH.unshift(File.dirname(__FILE__))

start_path_filename = ARGV[0]

def execute command
  puts command
  system(command)
end

REFERENCE = "/n/data1/genomes/bowtie-index/mm9/mm9.fa"
GTF = "/n/data1/genomes/bowtie-index/mm9/Ens_63/mm9.Ens_63.gtf"

CUFFLINKS_BIN = "/n/site/inst/Linux-x86_64/bioinfo/stowers.bio.brew/stage/cufflinks/cufflinks_2.0.2/cufflinks"

# bam files are assumed to be in their own sub-directory - as would be the case from running align.rb
# bam file names are probably all the same (tophat) and so we will use sub-directory folder to 
# name output
#
# except if we merge the bam files before hand...

bam_files = Dir.glob(File.join(start_path_filename, "**", "*.bam"))

Parallel.each(bam_files, :in_processes => 2) do |bam_file|
  bam_file = File.expand_path(bam_file)
  path = File.expand_path(File.dirname(bam_file))
  bam_name = File.basename(bam_file)
  bam_file_fields = bam_name.split(".")

  folder_name = bam_file_fields[0..-2].join('.') + "_cufflinks"

  cufflinks_dir = File.expand_path(File.join(path, "..", "cufflinks", folder_name))

  command = "mkdir -p #{cufflinks_dir}"
  execute command

  command = "#{CUFFLINKS_BIN} -p 4 -o #{cufflinks_dir} -G #{GTF} #{bam_file}"
  execute command


end
