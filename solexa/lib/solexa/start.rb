require 'logger'
require 'fileutils'
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
    method_option :multiplex, :type => :boolean, :aliases => "-m", :default => false
    def start
      log "Starting Flowcell: #{options[:flowcell]}"
      lanes = Lims::flowcell_lanes options[:flowcell]
      @flowcell = Flowcell.new options[:flowcell]
      puts @flowcell.path

      if options.multiplex?
        invoke "create_config_template"
      else
        invoke "create_config"
      end
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

    desc "create_config_template", "creates config.template.txt for multiplexed run"
    def create_config_template
    end
  end

end

