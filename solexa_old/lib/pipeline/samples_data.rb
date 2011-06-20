require 'pipeline/constants'

class SamplesData
  def self.for_flowcell flowcell_id, flowcell_directory
    samples_data = []
    if Dir.exists? flowcell_directory
      samples_directories_file = Dir.glob(File.join(flowcell_directory,"**/SamplesDirectories.csv"))
      if samples_directories_file.size != 1
        raise "ERROR: Number of SamplesDirectories.csv found in #{flowcell_directory}: #{samples_directories_file.size}"
      else
        full_samp_dir_path = File.expand_path(samples_directories_file[0])
        samples_data = self.from_samples_directories flowcell_id, full_samp_dir_path
      end
    else
      raise "ERROR: Flowcell Directory not found: #{flowcell_directory}"
    end
    samples_data
  end

  def self.from_samples_directories flowcell_id, samples_directories_file
    samples_data = self.parse_samples_directories samples_directories_file
    lane_data = self.get_lane_data flowcell_id

    samples_data = samples_data.collect do |sample_data|
      sample_data = self.clean_sample_data sample_data
      # add dist dir to sample data now
      dist_dir = lane_data[sample_data["Lane"]]
      if dist_dir
        sample_data["DistDir"] = dist_dir
      else
        puts "WARNING: Lane #{sample_data["Lane"]} Present in SamplesDirectories, but does not have distribution directory"
      end
      sample_data
    end
    samples_data
  end

  def self.parse_samples_directories samples_directories_file
    samples_data = []
    File.open(samples_directories_file, 'r') do |file|
      lines = file.readlines
      headers = lines.shift.chomp.split(",")
      samples_data = lines.collect {|line| Hash[*headers.zip(line.chomp.split(",")).flatten] }
    end
    samples_data
  end

  def self.get_lane_data flowcell_id
    lane_data = {}
    command = "#{SCRIPT_PATH}/ngsquery.pl fc_file_dirs #{flowcell_id}"
    results = %x[#{command}]
    #puts results
    lane_data = results.split("\n").inject({}) do |hash,line|
      data = line.split("\t")
      dist_dir = data[-2]
      lanes = data[-1].split(",")
      lanes.each do |lane|
        raise "ERROR: lane already has a distribution directory" if hash[lane]
        hash[lane] = dist_dir
      end
      hash
    end
    lane_data
  end

  def self.clean_sample_data sample_data
    sample_data.each do |key, value|
      sample_data[key] = value.gsub(/\s+/,"")
    end
    sample_data
  end
end

