#!/usr/bin/env ruby

# compares three MAQ .view files and returns variations present in
# either of the first two, but not the last one
# Expects files to have the same number of lines in the same
# order.
#
# call using compare_maq_views.rb 1.view 2.view control.view
#
# creates output file: 1_or_2_diff_control.bed

view_1_filename = ARGV[0]
view_2_filename = ARGV[1]
view_3_filename = ARGV[2]

view_1_name = File.basename(view_1_filename).split(".")[0..-2].join(".")
view_2_name = File.basename(view_2_filename).split(".")[0..-2].join(".")
view_3_name = File.basename(view_3_filename).split(".")[0..-2].join(".")

output_main_filename = "#{view_1_name}_and_#{view_2_name}_diff_#{view_3_name}.diff"
output_main_file = File.new(output_main_filename, 'w')
output_main_bed_filename = "#{view_1_name}_and_#{view_2_name}_diff_#{view_3_name}.bed"
output_main_bed_file = File.new(output_main_bed_filename, 'w')

output_1_filename = "#{view_1_name}_diff_#{view_3_name}_filtered.bed"
output_1_file = File.new(output_1_filename, 'w')
output_2_filename = "#{view_2_name}_diff_#{view_3_name}_filtered.bed"
output_2_file = File.new(output_2_filename, 'w')

VIEW_HEADERS = %w(chr loc ref con qual depth avg_hits hi_qual min_qual sec log_like third)

def line_to_hash line
  Hash[VIEW_HEADERS.zip(line.chomp.split("\t"))]
end

def same_location? data1, data2
  data1['chr'] == data2['chr'] and
    data1['loc'] == data2['loc'] and
    data1['ref'] == data2['ref']
end

def matching? data1, data2
  data1['con'] == data2['con']
end

def reads_present(data)
  data['con'] != 'N' and data['depth'] != '0'
end

def good_quality data
  data['qual'].to_i > 22
end

def good_depth data
  data['depth'].to_i > 4
end

HOMOZYGOUS_CODES = %w(A C G T)

def homozygous data
  HOMOZYGOUS_CODES.include? data['con']
end

hom1_count = 0
hom2_count = 0
no_hom_count = 0

stats = Hash.new(0)

def non_match_threshold_pass? data1, data2
  rtn = false
  if !matching?(data1, data2) and reads_present(data1) and reads_present(data2)
    if good_quality(data1) and good_quality(data2) and good_depth(data1) and good_depth(data2)
      hom1 = homozygous(data1)
      hom2 = homozygous(data2)
      if hom1 and hom2
        rtn = true
      end
    end
  end
  rtn
end

def collect_output data1, data2, data3, sample
  output = "#{data3['chr']}\t#{data3['loc']}\t#{data3['ref']}\t"
  %w(con depth qual).each_with_index do |attr, i|
    [data3, data1, data2].each_with_index do |d, j|
      output += "#{d[attr]}"
      output += "\t"
    end
  end
  output += sample
  output
end

def collect_header name1, name2, name3
  output = "chr\tloc\tref\t#{name3}\t#{name1}\t#{name2}\t#{name3}_depth\t#{name1}_depth\t#{name2}_depth\t#{name3}_qual\t#{name1}_qual\t#{name2}_qual\tsample"
  output
end

def to_bed data
  "#{data["chr"]}\t#{data["loc"]}\t#{data["loc"].to_i + 1}"
end

output_main_file.puts collect_header(view_1_name, view_2_name, view_3_name)

File.open(view_1_filename, 'r') do |f1|
  File.open(view_2_filename, 'r') do |f2|
    File.open(view_3_filename, 'r') do |f3|
      index = 1

      while(line1 = f1.gets)
        line2 = f2.gets
        line3 = f3.gets

        data1 = line_to_hash(line1)
        data2 = line_to_hash(line2)
        data3 = line_to_hash(line3)
        if !same_location? data1, data3
          puts "ERROR: not matching location"
          puts line1
          puts line3
        elsif !same_location? data2, data3
          puts "ERROR: not matching location"
          puts line2
          puts line3
        else
          affect_1 = false
          affect_2 = false
          if non_match_threshold_pass? data1, data3
            affect_1 = true
            output_1_file.puts to_bed(data1)
            output_main_bed_file.puts to_bed(data1)
          end
          if non_match_threshold_pass? data2, data3
            # puts data2.inspect
            # puts data3.inspect
            affect_2 = true
            output_2_file.puts to_bed(data2)
            output_main_bed_file.puts to_bed(data2)
          end
          sample = ""
          if affect_1 and affect_2
            sample = "both"
          elsif affect_1
            sample = view_1_name
          elsif affect_2
            sample = view_2_name
          else
            sample = "none"
          end

          if affect_1 or affect_2
            if sample == "none"
              puts "ERROR: none sample"
              puts data1.inspect
            end
            output_main_file.puts collect_output(data1,data2,data3,sample)
          end
        end

        puts "#{index}" if index % 10000 == 0

        index +=1
      end
    end
  end
end

output_main_file.close
output_main_bed_file.close
output_1_file.close
output_2_file.close

# stats.each do |k,v|
#   puts "#{k}\\t#{v}"
# end
