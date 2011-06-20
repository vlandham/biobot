
require 'net/ftp'

class SimpleFtp
  attr_accessor :server, :username, :password, :basedir
  def initialize server, user, pass, basedir
    self.server = server
    self.username = user
    self.password = pass
    self.basedir = basedir
    @ftp = nil
  end

  def clone
    connect
    if @ftp
      puts @ftp.status
    end

    FileUtils.mkdir_p basedir unless Dir.exists? basedir

    Dir.chdir basedir
    @ftp.chdir  basedir
    puts "changed to remote dir: #{basedir}"
    path = ["/"]
    clone_remote_dir path
    @ftp.close
  end

  def clone_remote_dir path

    files = get_files_and_directories
#    puts "files: "
#    puts files.to_s
    files.each do |fileinfo|
      filename, is_file = fileinfo
      if is_file
        if File.exists? filename
          puts "file exists: #{filename} skipping"
        else
          begin
            puts "attempting to download #{filename}"
            @ftp.getbinaryfile(filename, filename)
            puts "#{filename} download complete!"
          rescue
            puts "ERROR: downloading #{filename}"
          end
        end
      else
        FileUtils.mkdir_p filename unless Dir.exists? filename
        Dir.chdir filename
        @ftp.chdir(filename)
        path << filename
        puts "changed to #{filename} directory"

        clone_remote_dir path

        @ftp.chdir("..")
        Dir.chdir("..")
        path.pop
        puts "changed to #{path[-1]} directory"
      end
    end
  end

  def get_files_and_directories
    all_files = []
    @ftp.ls("-a").each do |fileline|
#      puts "fileline: #{fileline}"
      next unless fileline.size > 8
      filehold = fileline.split(" ")[8..-1] #in case there are spaces in the file
      filename = filehold.inject("") {|name, hold| name += " #{hold}"}.strip
      puts "filename: #{filename}"
      next unless((filename != ".") and (filename != ".."))
      if fileline[0..0] == '-'
        all_files << [filename, true]
      elsif fileline[0..0] == 'd'
        all_files << [filename, false]
      end
    end
    all_files
  end

  def connect
    if !@ftp
      @ftp = Net::FTP::new(server)
      @ftp.login(username,password)
    end
  end
end
