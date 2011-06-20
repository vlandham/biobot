
class MockLims
  def self.flowcell_lanes fcid, genome = "mm9"
    lanes = []
    (1..8).each do |num|
      lanes << "#{fcid}\t#{num}\t#{genome}\tfake\tfake\tfake\tfake\tfake\tfake\tfake\tfake"
    end
    lanes
  end
end
