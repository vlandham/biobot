require 'lib/constants'
require 'lib/flowcell'

class AdminScripter
  attr_reader flowcell_id

  def initialize fcid
    @flowcell_id = fcid.upcase
    @scripts_file = File.join(Paths.admin_path, "#{flowcell_id}.sh")
  end

  def create
    move_existing_file
    create_new_file
    write_header
    command = "cd /solexa/*#{@flowcell_id}/Data/Intensities/BaseCalls"
    write command
    command = "#{Paths.script_path}/ngsquery.pl fc_lane_library_samples #{@flowcell_id}"
    write command
  end

  def move_existing_file
    if File.exists? @scripts_file
      old_scripts_file_name = "#{@scripts_file}.old"
      puts "WARNING: #{@scripts_file} exists moving to #{old_scripts_file_name}"
      File.rename(@scripts_file, old_scripts_file_name)
    end
  end

  def write_header
	write "#!/bin/bash"
	write "# #{@flowcell_id}"
	write ""
  end

  def execute command
    results = %x[#{command}]
    results.split("\n").each {|line| script_file << "# " << line << endl}
  end

  def create_new_file
    @output_file = File.new(@scripts_file, 'w')
  end

  def close_file
    @output_file.close
  end

  def write line
    @output_file << line << "\n"
  end

end



File.open(script_file_name, "w") do |script_file|
	#this should probably be a template or something more formal. Oh well.


	script_file << command << endl


	script_file << endl << endl

	command = "#{SCRIPT_PATH}/config_maker.rb #{flowcell_id}"

	results = %x[#{command}]

	# add the output file to the command as we want it
	# to generate the file when we run this script for reals
	command = command + " config.txt"

	script_file << command << endl

	results.split("\n").each {|line| script_file << "# " << line << endl}

	script_file << endl

	log_file = "#{LOGS_PATH}/#{flowcell_id}.log"
	command = "touch #{log_file}"

	script_file << command << endl

	command = "echo 'eland_start, `date`' >> #{log_file}"

	script_file << command << endl

	command = "~/OLB-1.9.0/bin/setupBclToQseq.py -b /solexa/*#{flowcell_id}/Data/Intensities/BaseCalls --in-place --overwrite --GERALD ./config.txt"

	script_file << endl
	
	script_file << command << endl << endl

	command = "nohup make recursive -j 8 > ./make.out 2> make.err &"

	script_file << command << endl << endl

	script_file << "# after complete, run this command and paste results to wiki page" << endl
	script_file << "# fc_info #{flowcell_id}" << endl << endl
end
