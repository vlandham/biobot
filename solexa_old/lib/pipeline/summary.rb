require 'rexml/document'
require 'json'

class Summary

  @@flowcell_info =[{:xml_name => "", :json_name => "FCID"},
                    {:xml_name => "", :json_name => "chipYield"},
                    {:xml_name => "", :json_name => "machineName"},
                    {:xml_name => "", :json_name => "runDate"}]

  @@lane_titles = [{:xml_name => "sampleId", :print_name => "Sample Name"},
                {:xml_name => "laneNumber", :print_name => "Lane", :json_name => "laneID"},
                {:xml_name => "laneYield", :print_name => "Lane Yield (Mbases)", :json_name => "laneYield"},
                {:xml_name => "clusterCountRaw", :print_name => "Clusters (raw)", :json_name => "clusterCountRaw"},
                {:xml_name => "clusterCountPF", :print_name => "Clusters (PF)", :json_name => "clusterCountPF"},
                {:xml_name => "oneSig", :print_name => "1st Cycle Int (PF)", :json_name => "firstCycleInt"},
                {:xml_name => "signal20AsPctOf1", :print_name => "% intensity after 20 cycles (PF)", :json_name => "signal20AsPctOf1"},
                {:xml_name => "percentClustersPF", :print_name => "% PF Clusters", :json_name => "pctClustersPF"},
                {:xml_name => "percentUniquelyAlignedPF", :print_name => "% Align (PF)", :json_name => "pctAlignPF"},
                {:xml_name => "averageAlignScorePF", :print_name => "Alignment Score (PF)"},
                {:xml_name => "errorPF", :print_name => "% Error Rate (PF)", :json_name => "pctErrorPF"},
                {:xml_name => "sample", :json_name => "sample"},
                {:xml_name => "template", :json_name => "genomeVersion"},
                {:xml_name => "originalReadLength", :json_name => "readLength"},
                {:xml_name => "tileCountPF", :json_name => "tileCount"},
                {:xml_name => "lengthsList", :json_name => "lengthsList"},
                {:xml_name => "type", :json_name => "laneType"}]

  def initialize
    @all_lanes_data = []
  end

  def find_summary_files root_dir
    xml_file_pattern = "Summary.xml"
    xml_filenames = Dir.glob(File.join(root_dir, "**", xml_file_pattern))
    puts "Found: #{xml_filenames.size} #{xml_file_pattern} files"
    xml_filenames
  end

  def parse root_dir
    root_dir = File.expand_path root_dir
    raise "ERROR: #{root_dir} not found" unless Dir.exists? root_dir
    xml_filenames = find_summary_files root_dir

    all_found_lanes = []
    xml_filenames.each do |xml_file|
      xml_doc = REXML::Document.new File.new(xml_file)
      valid_lanes = get_valid_lanes xml_doc
      lanes_data = get_lanes_data xml_doc, valid_lanes

      check_for_duplicates lanes_data
      @all_lanes_data << lanes_data
    end

    @all_lanes_data.flatten!
    @all_lanes_data = @all_lanes_data.sort {|x,y| x["laneNumber"].to_i <=> y["laneNumber"].to_i }
  end

  def get_valid_lanes xml_doc
    # this gives us basic lane name data and which
    # lanes we should be looking at in the results summary
    valid_lanes = []
    xml_path = "Summary/Samples/Lane"
    lanes = extract_from xml_doc, xml_path
    if lanes.empty?
      # assume this Summary contains all lanes
      puts "valid lanes not found. Single Summary file?"
      valid_lanes = ["1","2","3","4","5","6","7","8"]
    else
      valid_lanes = lanes.collect {|lane| lane["laneNumber"]}
    end
    valid_lanes
  end

  def get_lanes_data xml_doc, valid_lanes
    xml_path = "Summary/Samples/Lane"
    samples_data = get_valid_lanes_data_from xml_doc, xml_path, valid_lanes
    # if this is a single sample, it won't have a samples/lane section
    samples_data = samples_data.empty? ? fake_samples_data(valid_lanes) : samples_data

    extra_data = []
    xml_path = "Summary/LaneResultsSummary/Read/Lane"
    extra_data << get_valid_lanes_data_from(xml_doc, xml_path, valid_lanes)

    xml_path = "Summary/LaneParameterSummary/Lane"
    extra_data << get_valid_lanes_data_from(xml_doc, xml_path, valid_lanes)

    lanes_data = samples_data.map do |samples_hash|
      lane_hash = samples_hash
      extra_data.each do |data|
        data.each do |data_hash|
          if samples_hash["laneNumber"] == data_hash["laneNumber"]
            lane_hash.merge! data_hash
          end
        end
      end
      lane_hash
    end
    lanes_data = process_lanes_data lanes_data
    lanes_data
  end

  def get_valid_lanes_data_from xml_doc, xml_path, valid_lanes
    lanes = extract_from xml_doc, xml_path
    lanes ||= []
    lane_data = lanes.select {|lane| valid_lanes.include? lane["laneNumber"]}
    lane_data
  end

  def fake_samples_data valid_lanes
    valid_lanes.inject([]) {|array, num| array << {"laneNumber" => num, "sampleId" => num}; array}
  end

  def extract_from xml_doc, xml_path
    xml_content = xml_doc.elements.to_a(xml_path)
    results = []
    xml_content.each do |line|
      data = extract_line_data line
      results << data
    end
    results
  end

  def extract_line_data lane
    lane_data = {}

    lane.each_element_with_text do |element|
      if element.size > 1
        lane_data_hash = {}
        element.elements.each {|element| lane_data_hash[element.name] = element.text}
        lane_data[element.name] = lane_data_hash
      else
        lane_data[element.name] = element.text
      end
    end
    lane_data
  end

  def process_lanes_data lanes_data
    # special processing for lane yield
    lanes_data.each do |lane_data|
      if lane_data["laneYield"]
        lane_data["laneYield"] = (lane_data["laneYield"].to_f / 1000).round.to_i.to_s
      end
      if lane_data["sample"] == "unknown" and lane_data["sampleId"]
        lane_data["sample"] = lane_data["sampleId"]
      end
    end
    lanes_data
  end

  def check_for_duplicates lanes
    @all_found_lanes ||= []

    lanes.each do |lane|
      all_xml_key = lane["sampleId"]
      if @all_found_lanes.include? all_xml_key
        puts "ERROR: lane already seen: #{all_xml_key}"
      end
      @all_found_lanes << all_xml_key
    end
  end

  def titles_for_csv
    @@lane_titles.select{|title| !title[:print_name].nil?}.collect {|title| [title[:print_name], title[:xml_name]]}
  end

  def titles_for_json
    @@lane_titles.select{|title| !title[:json_name].nil?}.collect {|title| [title[:json_name], title[:xml_name]]}
  end

  def to_json
    json_hash = {}
    json_lanes = @all_lanes_data.collect do |lane_data|
      json_lane_hash = {}
      titles_for_json.each do |json_title, xml_title|
        puts "ERROR #{xml_title} - #{json_title} not present" unless lane_data[xml_title]
        json_lane_hash[json_title] = format_data_json(lane_data[xml_title])
      end
      json_lane_hash
    end
    json_hash["lanes"] = json_lanes
    json_hash.to_json
  end

  def format_data_json data
    formatted_data = ""
    if data.nil?
      formatted_data = "0"
    elsif data.kind_of? Hash
      formatted_data = data["mean"]
    else
      formatted_data = data
    end
    formatted_data
  end

  def to_csv output_file, extra_headers
    headers = titles_for_csv
    print_headers = headers.collect {|header| header[0]}
    xml_headers = headers.collect {|header| header[1]}
    print_headers << extra_headers

    output_file << print_headers.join(", ") << "\n"
    @all_lanes_data.each do |lane_data|
      xml_headers.each do |header|
        formatted_data = format_for_csv lane_data[header]
        output_file << formatted_data << ", "
      end
      output_file << "\n"
    end
  end

  def format_for_csv data
    formatted_data = ""
    if data.nil?
      formatted_data = "0"
    elsif data.kind_of? Hash
      puts "ERROR: no mean or stdev in #{data.inspect}" unless data["mean"] and data["stdev"]
      formatted_data = data["mean"]
      formatted_data += " +\/- "
      formatted_data += data["stdev"]
    else
      formatted_data = data
    end
    formatted_data
  end
end

