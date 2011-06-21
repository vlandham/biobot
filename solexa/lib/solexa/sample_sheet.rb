
class SampleSheet
  attr_reader :path
  def initialize file_path
    raise "ERROR: #{file_path} does not exist" unless File.exist? file_path
    @path = file_path
  end

  def lanes
    @lanes ||= read_data
    @lanes
  end

  def valid?
    valid = true
    lanes.each do |lane|
      valid &= lane.size == 10
      valid &= lane["SampleProject"] != nil
      valid &= lane["SampleID"] != nil
      valid &= lane["Lane"] != nil
    end
    valid
  end

  def read_data
    data = []
    lines = File.open(@path, 'r').readlines
    header = lines.shift.chomp.split(",")
    lines.each do |line|
      line_data = line.chomp.split(",")
      data << Hash[header.zip(line_data)]
    end
    data
  end

end
