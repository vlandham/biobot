require 'fileutils'

require 'solexa/lims'
require 'solexa/flowcell'
require 'solexa/sample_sheet'

class PostRunner

  attr_reader :flowcell_id

  def initialize fcid
    @flowcell_id = fcid
    @test = true
  end

  def execute command
    puts command
    system(command) unless @test
  end

  def run
    flowcell = Flowcell.new @flowcell_id
    fastq_output_path = File.join(flowcell.unaligned_path, "all")
    fastq_groups = combine_fastq_files flowcell.unaligned_path, fastq_output_path
    run_fastqc fastq_output_path

    fastq_output_path = File.join(flowcell.aligned_path, "all")
    alignment_groups = move_alignment_files flowcell.aligned_path, alignment_output_path
  end

  def distribute_fastq_files fastq_groups, lims_distribution_data
    lims_distribution_data.each do |distribution|
      FileUtils.mkdir_p distribution[:path]
      distribution_groups = fastq_groups.select {|g| g[:lane] == distribution[:lane]}
      distribution_groups.each do |group|
        command = "cp #{group[:group_path]} #{distribution[:path]}"
        execute command
      end
    end
  end

  def distribute_fastqc fastqc_path, lims_distribution_data
    FASTQC_FOLDER = "fastqc"
    fastqc_dir = File.join(fastqc_path, FASTQC_FOLDER)
    raise "ERROR: no fastqc folder found at:#{fastqc_dir}" unless File.exists? fastqc_dir
    # only distribute once to each path
    already_distributed = []

    lims_distribution_data.each do |distribution|
      fastqc_distribution_dir = FIle.join(distribution[:path], FASTQC_FOLDER)
      unless already_distributed.include? fastqc_distribution_dir
        already_distributed << fastqc_distribution_dir
        FileUtils.mkdir_p fastqc_distribution_dir
        command = "cp -r #{fastqc_dir} #{fastqc_distribution_dir}"
        execute command
      end
    end
  end

  def distribute_alignment_files alignment_groups, lims_distribution_data
  end

  def move_alignment_files starting_path, output_path
  end

  # combines fastq files based on sub-directories
  # creates new considated fastq file for each
  # sample folder. Places them at starting_path
  # ASSUMPTION: fastq files have a specific
  # naming structure (defined in CASAVA 1.8
  # documentation). The names of these files
  # follows the pattern:
  # <sample name>_<barcode sequence>_L<lane>_R<read number>_<set number>.fastq.gz
  # This method combines all fastq files with the
  # same lane and barcode_sequence.
  # It will raise errors if the fastq files to be
  # combined do not have the same sample names
  # EFFECT: each barcoded sample in the same
  # lane now has its own fastq.gz file in the
  # root of the output_path. These files will
  # have the following name pattern:
  # s_<lane>_<barcode>.fastq.gz
  # The output path will be created if necessary
  def combine_fastq_files starting_path, output_path
    puts "creating path: #{output_path}"
    FileUtils.mkdir_p output_path

    fastq_files = Dir.glob(File.join(starting_path, "**", "*.fastq.gz"))
    raise "ERROR: no fastq files found in #{starting_path}" if fastq_files.empty?
    puts "#{fastq_files.size} fastq files found in #{starting_path}"

    # get the lane, barcode, and sample name for the fastq files
    fastq_file_data = get_fastq_file_data fastq_files
    # group them based on barcode and sample
    fastq_groups = group_fastq_files fastq_file_data, output_path
    # perform combination step
    combine_fastq_files fastq_groups
    fastq_groups
  end

  # runs fastqc on all relevant files in fastq_path
  # output is genearted fastq_path/fastqc
  def run_fastqc fastq_path
    cwd = Dir.pwd
    # fastqc script expects us to be in
    # same directory as files to work on
    # TODO: make fastqc script capable of
    # working outside the current directory
    raise "ERROR: #{fastq_path} not found" unless File.exists? fastq_path
    raise "ERROR: #{fastq_path} not directory" unless File.directory? fastq_path
    execute "cd #{fastq_path}"
    script = File.join(Paths.script_path, "fastqc.pl")
    command = "#{script} --files *.fastq.gz"
    execute "cd #{cwd}"
  end

  # actually combines the related fastq files
  # using cat
  def combine_fastq_files fastq_groups, output_path
    fastq_groups.each do |group|
      # this is the Illumina recommended approach to combining these fastq files.
      # See the Casava 1.8 Users Guide for proof
      files_list = group[:paths].join(" ")
      command = "cat #{files_list} > #{group[:group_path]}"
      execute command
    end
  end

  # returns an array of hashes, one for each
  # new combined fastq file to be created
  # Each hash will have the name of the
  # combined fastq file and an Array of
  # paths that the group contains
  def group_fastq_files fastq_file_data, output_path
    groups = {}
    fastq_file_data.each do |data|
      group_key = "s_#{data[:lane]}_#{data[:barcode]}.fastq.gz"
      if groups.include? group_key
        if groups[group_key][:sample_name] == data[:sample_name]
          groups[group_key][:paths] << data[:path]
        else
          raise "ERROR: sample names not matching #{group_key} - #{data[:path]}"
        end
      else
        group_path = File.join(output_path, group_key)
        groups[group_key] = {:group_name => group_key, :group_path => group_path,
                             :sample_name => data[:sample_name],
                             :paths => [data[:path]], :lane => data[:lane]}
      end
    end
    groups.values
  end

  # returns Array of hashes for files in input
  # Hash includes sample_name, barcode, lane,
  # basename, and full path
  def get_fastq_file_data fastq_files
    # this should capture correctly even when the sample name
    # has an underscore in it. Hopefully the sample name does not
    # have an underscore in it though...
    FASTQ_NAME_PATTERN = /(.*)_([ATCG]+)_L(\d{3})_R(\d)_(\d{3}).fastq.gz/

    fastq_file_data = fastq_files.collect do |fastq_file|
      fastq_name = File.basename(fastq_file)
      match = fastq_name =~ FASTQ_NAME_PATTERN
      raise "ERROR: #{fastq_file} does not match expected file name pattern"
      data = {:name => fastq_name, :path => fastq_file,
              :sample_name => $1, :barcode => $2, :lane => $3.to_i}
      data
    end
    fastq_file_data
  end

  def get_sample_sheets_paths starting_path
    sample_sheet_paths = Dir.glob(File.join(starting_path, "**", "SampleSheet.csv"))
  end
end
