require 'fileutils'

class Dir
  def self.iterate_over file_pattern
    base_dir = Dir.pwd
    files = Dir.glob file_pattern
    files.each do |file|
      dir = File.dirname(File.expand_path(file))
      base_name = File.basename(file)
      Dir.chdir dir
      yield dir, base_name
      Dir.chdir base_dir
    end
  end
end
