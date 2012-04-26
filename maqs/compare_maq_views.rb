#!/usr/bin/env ruby

# compares two MAQ .view files and returns variations present in
# one file but not the other.
# Expects both files to have the same number of lines in the same
# order.
#
# call using compare_maq_views.rb 1.view 2.view
#
# creates output file: 1_diff_2.view

view_1_filename = ARGV[0]
view_2_filename = ARGV[1]

view_1_name = File.basename(view_1_filename).split(".")[0..-2].join(".")
view_2_name = File.basename(view_2_filename).split(".")[0..-2].join(".")

output_1_filename = "#{view_1_name}_diff_#{view_2_name}_filtered.view"
output_1_file = File.new(output_1_filename, 'w')
output_2_filename = "#{view_2_name}_diff_#{view_1_name}_filtered.view"
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

File.open(view_1_filename, 'r') do |f1|
  File.open(view_2_filename, 'r') do |f2|
    index = 1
    while(line1 = f1.gets)
      line2 = f2.gets
      data1 = line_to_hash(line1)
      data2 = line_to_hash(line2)
      if !same_location? data1, data2
        puts "ERROR: not matching location"
        puts line1
        puts line2
      else
        if !matching?(data1, data2) and reads_present(data1) and reads_present(data2)
          if good_quality(data1) and good_quality(data2) and good_depth(data1) and good_depth(data2)
            hom1 = homozygous(data1)
            hom2 = homozygous(data2)

            if hom1 and hom2
              output_1_file.puts line1.chomp
              output_2_file.puts line2.chomp
              stats['both_hom_count'] += 1
            elsif hom1
              stats['hom1_count'] += 1
            elsif hom2
              stats['hom2_count'] += 1
            else
              stats['no_hom_count'] += 1
            end
          end
        end
      end

      puts "#{index}" if index % 10000 == 0

      index +=1
    end
  end
end

output_1_file.close
output_2_file.close

stats.each do |k,v|
  puts "#{k}\t#{v}"
end
