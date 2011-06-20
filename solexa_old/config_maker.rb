#! /usr/bin/env ruby
SCRIPT_PATH= "/qcdata/SIMR_pipeline_scripts"
$LOAD_PATH.unshift(SCRIPT_PATH)

require 'erb'

CONVERSIONS = { 
  "Drosophila_melanogaster.BDGP5.4.54" => [/.*BDGP5.*/],
  "ce6" => [/ce6/],
  "dp3" => [/dp3/],
  "droSim1" => [/.*simulans.*/],
  "droAna2" => [/.*ananassae.*/],
  "mm9" => [/.*mm9.*/, /.*musculus.*/],
  "sacCer2" => [/.*sac[C|c]er2.*/, /.*[C|c]erevisiae.*/], 
  "hg19" => [/.*[H|h]uman.*/,/.*hg19.*/,/.*[S|s]apien.*/],
  "phiXSquashes" => [/.*phiX.*/, /.*phix.*/],
  "dm3" => [/.*dm3.*/, /.*[D|d]rosophila.*/],
  "pombe_9-2010" => [/.*[P|p]ombe.*/]
}

def query_ngslims flowcell_id
  query_results = %x[perl #{SCRIPT_PATH}/ngsquery.pl fc_lane_library_samples #{flowcell_id}]
  query_results.force_encoding("iso-8859-1")
  rows = query_results.split("\n")
  # puts rows.to_s
  parsed_rows = Array.new
  rows.each do |row|  
    parsed_row = Hash.new
    split_row = row.split("\t")
    [:flowcell, :number, :organism, :name, :samples, :lab, :unknown, :cycles, :type, :protocol].each_with_index do |header, index|
      parsed_row[header] = split_row[index]
    end
    parsed_rows << parsed_row
  end
  # puts parsed_rows.to_s
  parsed_rows
end

def get_organism row
  new_type = row[:organism] 
  matched = false
  CONVERSIONS.each do |valid_name, matches|
    matches.each do |match|
      if new_type =~ match
        new_type = valid_name
        matched = true
        break
      end
    end
    break if matched
  end
  
  puts "ERROR: #{new_type} not in conversions table" unless matched
  new_type
end

def get_analysis_type row
  row[:protocol].downcase =~ /.*single.*/ ? "eland_extended" : "eland_pair"
end

def clean_rows rows
  new_rows = rows.map do |row|
    new_row = Hash.new
    new_row[:organism] = get_organism(row)
    new_row[:analysis] = get_analysis_type(row)
    new_row[:number] = row[:number]
    new_row
  end
  # puts new_rows.to_s
  new_rows
end

def row_equal row1, row2
retn = true
row1.each do |key, value|
  if key != :number && row2[key] != value
    retn = false
    break
  end
end
retn
end

def combine_rows rows
  combined_rows = Array.new
  current_row = 0
  combined_rows << rows[current_row]
  rows[1..-1].each do |row|
    # puts row.to_s
    combo_row = combined_rows[current_row]
    if row_equal combo_row, row
     combo_row[:number] = combo_row[:number].to_s << row[:number]
     combined_rows[current_row] = combo_row
    else
      combined_rows << row
      current_row += 1
    end
  end
  combined_rows
end

flowcell_id = ARGV[0]

output_file = ARGV[1]

if flowcell_id
  puts "Flowcell ID: #{flowcell_id}"
else
  puts "ERROR: no flow cell ID provided"
  exit
end

@raw_rows = query_ngslims(flowcell_id)

if @raw_rows.empty?
  puts "ERROR: invalid Flowcell ID: #{flowcell_id}"
  exit
end
             
@rows = clean_rows(@raw_rows) 

@rows = combine_rows(@rows)            

template = ERB.new File.new("#{SCRIPT_PATH}/config_template.erb").read, nil, "%<>"
output = template.result(binding)

if output_file
	File.open(output_file, 'w') do |file|
  		file << output
	end
else
	puts output	
end

