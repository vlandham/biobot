
class FlowcellLane
  GENOME_TRANSLATIONS = {
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

  FIELDS = [:flowcell, :number, :organism, :name, :samples, :lab, :unknown, :cycles, :type, :protocol]

  attr_accessor *FIELDS

  def initialize line
    populate_with line
    clean
  end

  def equal other_line
    retn = true
    self.each do |field, value|
      if field != :number && other_line.send(field) != value
        retn = false
        break
      end
    end
    retn
  end

  def combine other_line
    self.number = self.number.to_s + other_line.number.to_s
  end

  def each
    FIELDS.each do |field|
      yield field, self.send(field)
    end
  end

  def to_s
    values = []
    self.each do |field, value|
      values << value
    end
    values.join("\t")
  end

  private

  def populate_with line
    split_row = line.split("\t")
    FIELDS.each_with_index do |header, index|
       equals_method = header.to_s + "="
       self.send equals_method, split_row[index] if self.respond_to? equals_method
    end
  end

  def clean
    clean_analysis_type
    clean_organism
  end

  def clean_analysis_type
    self.protocol = self.protocol.downcase =~ /.*paired.*/ ? "eland_pair" : "eland_extended"
  end

  def clean_organism
    new_type = self.organism
    matched = false
    GENOME_TRANSLATIONS.each do |valid_name, matches|
      matches.each do |match|
        if new_type =~ match
          new_type = valid_name
          matched = true
          break
        end
      end
      break if matched
    end
    raise "ERROR: #{new_type} not in conversions table" unless matched
    self.organism = new_type
  end
end
