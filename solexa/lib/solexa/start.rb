require 'rubygems'
require 'thor'

require 'logger'
require 'fileutils'

require 'solexa'
require 'solexa/constants'

def log output, level = :debug
  string_output = output.to_s
  $LOG ||= Logger.new('solexa_start.log', 0, 100 * 1024 * 1024)
  $LOG.send level, string_output
  puts string_output
end

def error output
  log output
  exit
end

module Solexa
  class Start < Thor
    class_option :flowcell, :type => :string, :aliases => "-f", :required => true
    desc "start", "begin the solexa pipeline"
    def start
      log "Starting Flowcell: #{options[:flowcell]}"
      lanes = Lims::flowcell_lanes options[:flowcell]
      @flowcell = Flowcell.new options[:flowcell], lanes

      sample_sheet_path = File.join(@flowcell.basecalls_path, "SampleSheet.csv")
      invoke "check_sample_sheet", sample_sheet_path
      params = {:basecalls_path => @flowcell.basecalls_path,
                :output_path => @flowcell.unaligned_path,
                :sample_sheet_path => sample_sheet_path}
      invoke "run_bcl_to_fastqc", params

      config_file_path = File.join(@flowcell.basecalls_path, "config.txt")
      invoke "create_config", :output_file => config_file_path
    end

    desc "check_sample_sheet", "ensures sample sheet is present and valid"
    def check_sample_sheet(sample_sheet_file)
      raise "ERROR: #{sample_sheet_file} does not exist" unless File.exists? sample_sheet_file
      SampleSheet.new sample_sheet_file
      raise "ERROR: #{sample_sheet_file} is not valid" unless SampleSheet.valid?
      log "Sample Sheet Looks Valid"
    end

    desc "run_bcl_to_fastqc", "run the casava script to convert bcl files to fastqc files"
    method_option :basecalls_path, :type => :string, :required => true
    method_option :output_path, :type => :string, :required => true
    method_option :sample_sheet_path, :type => :string, :required => true
    def run_bcl_to_fastq
      log "Running bcl to fastqc conversion"
      invoke "check_sample_sheet", options[:sample_sheet_path]

      command = File.expand_path(File.join(Paths.casava_bin_path, "configureBclToFastq.pl"))
      command += " --input-dir #{options[:basecalls_path]}"
      command += " --output-dir #{options[:output_path]}"
      command += " --sample-sheet #{options[:sample_sheet_path]}"
      puts command
      system(command)

      make_command = "cd #{options[:output_path]}; make -j 8"
      puts make_command
      system(make_command)
    end

    desc "create_config", "creates config.txt file for GERALD run"
    method_option :output_file, :type => :string, :aliases => "-o"
    def create_config
      flowcell = Flowcell.new options[:flowcell]
      if options[:output_file]
        File.open(options[:output_file], 'w') do |file|
          file << flowcell.to_s
        end
      else
        puts flowcell.to_s
      end
    end
  end

end

