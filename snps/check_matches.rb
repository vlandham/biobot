#!/usr/bin/env ruby

csv_filename = ARGV[0]
vcf_filename = ARGV[1]
begin
output_filename = "check.out.txt"
outputfile = File.new(output_filename, 'w')

raise "ERROR: csv file missing" unless csv_filename
raise "ERROR: vcf file missing" unless vcf_filename


@chrom_hash = { "2L" => 10, "2LHet" => 15, "2R" => 20, "3L" => 30, "3R" => 40, "X" => 50, "Y" => 60, "4" => 70}

def translate(chrom_pos)
  #chrom = chrom_pos.split("").inject("") {|count, char,index| count += char.to_i.to_s if char != ':'; count}
  #chrom = chrom_pos.hash
  split = chrom_pos.split(":")
  chrom = @chrom_hash[split[0]]
  chrom ||= 1
  chrom = (chrom*10000000000)+split[1].to_i
  #puts "#{chrom_pos} => #{chrom}"
  chrom
end

csv_lines = File.open(csv_filename, 'r') {|csv_file| csv_lines = csv_file.readlines}

header = csv_lines.shift.chomp.gsub(/"/,"").split(",")
csv_data = csv_lines.collect do |line|
  data = Hash[header.zip(line.chomp.gsub(/"/,"").split(","))]
  data["id"]  = translate("#{data["Chrom"]}:#{data["Position"]}")
  data
end

csv_data = csv_data.sort {|x,y| x["id"] <=> y["id"]}

csv_data_copy = csv_data

coverage_file = File.open(vcf_filename, 'r')
header = nil 
index = 0 
coverage_file.each_line do |line|
  next if line.chomp.empty?

  index += 1
  split_data = line.chomp.split("\t")
  if !header
    puts "header: #{split_data.inspect}."
    header = line.chomp.split("\s") 
    next
  end
  
  data_id = translate(split_data[0])
  
  puts "index: #{index} location: #{data_id} min: #{csv_data[0]["id"]}" if (index % 1000) == 0
  #if data_id  < csv_data[0]["id"]
   # puts "skipping #{split_data[0]} #{csv_data[0]["Chrom"]}:#{csv_data[0]["Position"]}" if (index % 1000) == 0
   # next
  #end

  data = Hash[header.zip(split_data)]
  puts data.inspect

  #data_id = data["Locus"]

  csv_data.each_with_index do |csv,index|
    if csv["id"] == data_id
      csv_key = "#{csv["Chrom"]}:#{csv["Position"]}"
      puts "match id: #{csv_key} -- #{data["Locus"]}"
      if csv_key == data["Locus"]

        
        puts "Match found #{csv["id"]} - #{data_id}"
        #split_data.insert 8, data["Total_Depth"]
        #split_data.insert 9, data["ds_base_counts"]

        #outputfile << split_data.join(",") << "\n"
        #outputfile << line << "\n"
        csv_data_copy.delete csv 
      end
    end
  end

  csv_data = csv_data_copy

  if csv_data.empty?
    puts "all found. breaking"
    break
  end

end
ensure
puts "# of csv left: #{csv_data.size}"
#puts csv_data.inspect
outputfile.close
end
