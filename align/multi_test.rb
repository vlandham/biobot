#!/usr/bin/env ruby

def execute command
  puts command
  %x[#{command}]
end

USERS = 1
THREADS = 2
MAIN_DIR = "/scratch/jfv/test_dm3_align/multiuser"
FASTQ_FILES = ["ctbp_ip.fastq.gz","ctbp_wce.fastq.gz"]
DOWNLOAD_DIR = "/n/projects/jjj/genomics_course/sequence_data/"
BOWTIE_INDEX = File.join(MAIN_DIR, "d_melanogaster_fb5_22.ebwt", "d_melanogaster_fb5_22")
ALIGN_SCRIPT = File.join(MAIN_DIR, "align_script.sh")
threads = []
times = []
total_start_time = Time.now
USERS.times do |user|
  threads << Thread.new(user) do |user_index|
    user_start_time = Time.now
    working_dir = File.join(MAIN_DIR, "user_#{user_index}")
    command = "mkdir -p #{working_dir}"
    execute command

    FASTQ_FILES.each do |file|
      origin = File.join(DOWNLOAD_DIR, file)
      dest = File.join(working_dir, file)
      command = "cp #{origin} #{dest}"
      execute command
    end

    execute "#{ALIGN_SCRIPT} #{working_dir} #{THREADS}"

    #FASTQ_FILES.each do |fastq_file|
      #command = "cd #{working_dir}"
      #fastq_file = File.join(working_dir, fastq_file)
      #execute command
      #command = "/bin/bash bowtie --solexa1.3-quals -S -p #{THREADS} ../d_melanogaster_fb5_22.ebwt/d_melanogaster_fb5_22 <\(gunzip -c #{fastq_file}\) > #{fastq_file}.sam"
      #execute command
    #end

    user_end_time = Time.now
    time_data = ["User #{user_index}", (user_end_time - user_start_time)]
    times << time_data
  end
end

threads.each {|thread| thread.join}

total_end_time = Time.now

times << ["Total", (total_end_time - total_start_time)]

times.each do |title, time|
  puts "#{title}: #{time} seconds"
end
