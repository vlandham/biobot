require 'rubygems'
require 'thor'

require 'logger'
require 'fileutils'

require 'solexa'
require 'solexa/paths'

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
    desc "init", "performs configuration checks and creates admin script to run pipeline"
    def init
      log "Starting Flowcell: #{options[:flowcell]}"
      lanes = Lims::flowcell_lanes options[:flowcell]
      @flowcell = Flowcell.new options[:flowcell], lanes

      invoke "check_sample_sheet", @flowcell.sample_sheet_path
      invoke "create_admin_script"
    end

    desc "start", "starts the solexa pipeline"
    def start
      puts "Starting pipeline for #{options[:flowcell]}"
      invoke "run_admin_script"
    end

    def align
      log "Starting Algin Flowcell: #{options[:flowcell]}"
      lanes = Lims::flowcell_lanes options[:flowcell]
      @flowcell = Flowcell.new options[:flowcell], lanes
    end

    def post_run
      runner = PostRunner.new options[:flowcell]
      runner.run
    end

    desc "create_admin_script", "creates admin script to be used to kickstart solexa pipeline"
    def create_admin_script
      scripter = AdminScripter.new options[:flowcell]
      scripter.create
    end

    desc "run_admin_script", "runs admin script for the provided flowcell id"
    def run_admin_script
      admin_script = File.join(Paths.admin_path, "#{options[:flowcell]}.sh")
      raise "ERROR: admin script not found: #{admin_script}" unless File.exists? admin_script
      puts "Running Admin script at: #{admin_script}"
      system("chmod +x #{admin_script}")
      system(admin_script)
    end

    desc "check_sample_sheet", "ensures sample sheet is present and valid"
    def check_sample_sheet(sample_sheet_file)
      raise "ERROR: #{sample_sheet_file} does not exist" unless File.exists? sample_sheet_file
      SampleSheet.new sample_sheet_file
      raise "ERROR: #{sample_sheet_file} is not valid" unless SampleSheet.valid?
      log "Sample Sheet Looks Valid"
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

