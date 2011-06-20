require 'solexa/constants'


class Flowcell

  attr_reader :id, :path, :lanes

  def initialize id, raw_lanes
    @id = id
    @path = find_path
    all_lanes = process_lanes raw_lanes
    @lanes = combine_lanes all_lanes
  end

  def each_lane
    @lanes.each {|lane| yield lane}
  end

  def to_s
    template = ERB.new File.new("#{Paths::template_path}/config_template.erb").read, nil, "%<>"
    template.result(binding)
  end

  private

  def combine_lanes all_lanes
    current_row = 0
    combined_lanes = [all_lanes[current_row]]
    all_lanes[1..-1].each do |lane|
      combo_lane = combined_lanes[current_row]
      if combo_lane.equal lane
        combo_lane.combine lane
        combo_lane.combine lane
        combined_lanes[current_row] = combo_lane
      else
        combined_lanes << lane
        current_row += 1
      end
    end
    combined_lanes
  end

  def find_path
    path_pattern = File.join(Paths.root_path, "*#{id}", Paths.basecalls_path)
    paths = Dir.glob(path_pattern)
    if paths.size > 1
      raise "ERROR: multiple matching flowcell paths:\n#{paths.inspect}"
    elsif paths.size < 1
      raise "ERROR: no flowcell path found for:\n#{path_pattern}"
    end
    paths[0]
  end

  def process_lanes raw_lanes
    parsed_rows = raw_lanes.collect {|row| FlowcellLane.new row}
    parsed_rows
  end
end
