#!/usr/bin/env ruby

#
# About: convert gtf file downloaded from Illumina's igenome
# into gff3 format file to be used for custom genome in IGV genome browser
#
# Based on looking at one of the gff3 files on the broad's website. (WS201).
#
# First, it goes through the gtf and outputs all the CDS lines. While iterating
# through the gtf file, the script is also collecting transcript information.
# It then outputs a mRNA line for each transcript found from the gtf file.
#
# This might be the wrong way to do it - but does provide similar looking output
# as from the built in genomes.
#

input_gtff_filename = ARGV[0]

SECTIONS = [:chrom, :source, :type, :start, :end, :score, :strand, :phase]

if !input_gtff_filename
  puts "usage: gtf2gff <gtf_file>"
  exit(1)
end

if !File.exists?(input_gtff_filename)
  puts "ERROR: file not found:"
  puts input_gtff_filename
  exit(1)
end

counts = Hash.new(0)

@transcripts = Hash.new

def update_transcripts sections, fields
    transcript = @transcripts[fields["transcript_id"]]
    if transcript
      transcript[:start] = [transcript[:start].to_i, sections[3].to_i].min
      transcript[:end] = [transcript[:end].to_i, sections[4].to_i].max
    else
      transcript = {}
      SECTIONS.each_with_index do |key, index|
        transcript[key] = sections[index]
      end
      transcript[:source] = "Coding_transcript"
      transcript[:type] = "mRNA"
      transcript[:phase] = "."
      transcript[:id] = "Transcript:#{fields["transcript_id"]}"
      transcript[:cds] = fields["gene_id"]
    end
    @transcripts[fields["transcript_id"]] = transcript
    transcript
end

File.open(input_gtff_filename, 'r') do |file|
  file.each_line do |line|
    sections = line.chomp.split("\t")
    next if sections[2] != "CDS"
    fields = Hash[sections[8].gsub("\"","").split(";").collect {|s| s.strip.split(" ")}]

    transcript = update_transcripts sections, fields
    field_out = "\tID=CDS:#{fields["gene_id"]};Parent=#{transcript[:id]}"
    output = sections[0..7].join("\t") + field_out
    puts output

    counts[sections[2]] += 1
  end
end

@transcripts.values.each do |transcript|
  transcript_data = []
  SECTIONS.each do |section|
    transcript_data << transcript[section]
  end
  transcript_fields_output = "ID=#{transcript[:id]};cds=#{transcript[:cds]}"
  transcript_data << transcript_fields_output
  puts transcript_data.join("\t")
end

#puts counts.inspect
