#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require 'pipeline'

@extra_titles = ["Cluster; Align", "Q scores", "GC content", "Adapter-dimer", "Anoja Comments"]

root_dir = ARGV[0]
flowcell_id = ARGV[1]

output_filename = "AllSummary"
if flowcell_id
  output_filename += "_#{flowcell_id}"
end
output_filename += ".csv"

raise "ERROR: call: combine_summary [ROOT_DIR]" unless root_dir

output_filename = File.join(root_dir, output_filename)
puts "outputing to: #{output_filename}"
output_file = File.new(output_filename, 'w')
# output to file


summary = Summary.new

summary.parse root_dir

summary.to_csv output_file, @extra_titles

output_file.close

puts summary.to_json
