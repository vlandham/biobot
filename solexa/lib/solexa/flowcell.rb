require 'solexa/paths'

class Flowcell

  attr_reader :id, :base_path, :basecalls_path, :unaligned_path, :aligned_path
  attr_reader :sample_sheet_path, :config_file_path
  attr_reader :lanes

  def initialize id, raw_lanes
    @id = id
    @base_path = find_path
    @basecalls_path = File.join(@base_path, Paths.basecalls_path)
    @unaligned_path = File.join(@base_path, Paths.unaligned_path)
    @aligned_path = File.join(@base_path, Paths.aligned_path)
    @sample_sheet_path = File.join(@basecalls_path, "SampleSheet.csv")
    @config_file_path = File.join(@basecalls_path, "config.txt")
    @pipeline_bin = File.join(Paths.script_path, "pipeline", "solexa")
    all_lanes = process_lanes raw_lanes
    @lanes = combine_lanes all_lanes
  end

  def each_lane
    @lanes.each {|lane| yield lane}
  end

  def to_s
    template = ERB.new File.new(File.join(Paths::template_path,"config_template.erb")).read, nil, "%<>"
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
    path_pattern = File.join(Paths.root_path, "*#{id}")
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
