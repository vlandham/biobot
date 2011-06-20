#! /usr/bin/env ruby

# super quick hack to automate the normal process used to startup the pipeline

SCRIPT_PATH = "/qcdata/SIMR_pipeline_scripts"
ADMIN_PATH = "/qcdata/Admin"
LOGS_PATH = "/qcdata/log"
 
flowcell_id = ARGV[0]

if flowcell_id
	puts "Flowcell ID: #{flowcell_id}"
else
	puts "ERROR: no flow cell ID provided"
	exit
end

flowcell_id = flowcell_id.upcase

script_file_name = "#{ADMIN_PATH}/#{flowcell_id}.sh"

if File.exists?(script_file_name)
	puts "WARNING: #{script_file_name} exists. moving to #{script_file_name}.old"
	File.rename(script_file_name, script_file_name + ".old")
end

endl = "\n"

File.open(script_file_name, "w") do |script_file|
	#this should probably be a template or something more formal. Oh well.

	script_file << "#!/bin/bash" << endl
	script_file << "# #{flowcell_id}" << endl
	script_file << endl

	command = "cd /solexa/*#{flowcell_id}/Data/Intensities/BaseCalls"

	script_file << command << endl << endl

	command = "#{SCRIPT_PATH}/ngsquery.pl fc_lane_library_samples #{flowcell_id}"

	script_file << command << endl

	results = %x[#{command}]
	results.split("\n").each {|line| script_file << "# " << line << endl}

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
