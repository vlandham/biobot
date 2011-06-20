
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/mock_lims')

describe FlowcellLane do
  it "should be created from lims input line" do
    fcid = "123"
    genome = "mm9"
    lims_data = MockLims.flowcell_lanes fcid, genome
    lims_data.size.should == 8 #remove if needed. just testing stub
    lims_data.each do |line|
      flowcell_lane = FlowcellLane.new line
      flowcell_lane.flowcell.should == fcid
      flowcell_lane.organism.should == genome
      flowcell_lane.protocol.should == "eland_extended"
    end
  end
end
