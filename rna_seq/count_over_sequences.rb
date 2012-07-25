#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fastqc_reader'
require 'json'


fastqc_reader = FastqcReader.new(ARGV[0],ARGV[1])

data = fastqc_reader.data

File.open("fasqc.json",'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(data.to_json))
end

data.each do |name, data|
  overrep_data = data["Overrepresented sequences"]
  total = 0.0
  tru_total = 0.0
  overrep_data.each do |overrep|
    per = overrep["Percentage"].to_f
    total += per
    if overrep["Possible Source"] =~ /TruSeq/
      tru_total += per
    end
  end

  puts "#{name}\t#{total}\t#{tru_total}"
end

