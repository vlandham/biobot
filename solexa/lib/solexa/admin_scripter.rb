require 'lib/paths'
require 'lib/flowcell'

class AdminScripter
  attr_reader flowcell_id

  def initialize fcid
    @flowcell_id = fcid.upcase
    @scripts_file = File.join(Paths.admin_path, "#{flowcell_id}.sh")
  end

  def create
    move_existing_admin_file
    create_admin_file
    write_admin_header

    @flowcell = Flowcell.new @flowcell_id

    command = "cd #{@flowcell.basecalls_path}"
    write command
    command = "#{Paths.script_path}/ngsquery.pl fc_lane_library_samples #{@flowcell_id}"
    write command

    command = "#{Paths.pipeline_bin} create_config -f #{@flowcell_id} -o #{@flowcell.config_file_path}"
    write command

    config_content = @flowcell.to_s
    config_content.split("\n").each {|line| write "# #{line}"}

    command = configure_command
    write command

    command = "cd #{@flowcell_id.output_path}"
    write command

    command = "nohup make -j 8"
    command += " POST_RUN_COMMAND=\"#{Paths.pipeline_bin} align -f #{@flowcell.id}\""
    command += " > ./make.out 2> make.err &"
    write command

    write_admin_footer
    close_admin_file
  end

  def move_existing_admin_file
    if File.exists? @scripts_file
      old_scripts_file_name = "#{@scripts_file}.old"
      puts "WARNING: #{@scripts_file} exists moving to #{old_scripts_file_name}"
      File.rename(@scripts_file, old_scripts_file_name)
    end
  end

  def configure_command
    params = {:basecalls_path => @flowcell.basecalls_path,
              :output_path => @flowcell.unaligned_path,
              :sample_sheet_path => @flowcell.sample_sheet_path}

    command = File.expand_path(File.join(Paths.casava_bin_path, "configureBclToFastq.pl"))
    command += " --input-dir #{options[:basecalls_path]}"
    command += " --output-dir #{options[:output_path]}"
    command += " --sample-sheet #{options[:sample_sheet_path]}"
    command
  end

  def write_admin_header
	  write "#!/bin/bash"
	  write "# #{@flowcell_id}"
	  write ""
  end

  def write_admin_footer
    write "# after complete, run this command and paste results to wiki page"
    write "# fc_info #{flowcell_id}"
    write ""
  end

  def create_admin_file
    @output_file = File.new(@scripts_file, 'w')
  end

  def close_admin_file
    @output_file.close
  end

  def write line
    @output_file << line << "\n"
  end
end

