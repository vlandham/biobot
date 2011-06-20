
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/mock_lims')

describe FlowcellLane do

  before(:each) do
    @fcid = "123"
    @genome = "mm9"
    @lims_data = MockLims.flowcell_lanes @fcid, @genome
    @flowcell_lanes = @lims_data.collect {|line| FlowcellLane.new line}
  end

  it "should be created from lims input line" do
    @lims_data.size.should == 8 #remove if needed. just testing stub
    @lims_data.each do |line|
      flowcell_lane = FlowcellLane.new line
      flowcell_lane.flowcell.should == @fcid
      flowcell_lane.organism.should == @genome
      flowcell_lane.protocol.should == "eland_extended"
    end
  end

  it "should find similar lines as equal" do
    @flowcell_lanes.each_with_index do |lane, index|
      next if index == 0
      other_lane = @flowcell_lanes[index-1]
      lane.equal(other_lane).should == true
      other_lane.equal(lane).should == true
    end
  end

  it "should find different lanes different" do
    alt_flowcell_id = "234"
    alt_genome = "hg19"
    alt_lims_data = MockLims.flowcell_lanes alt_flowcell_id, alt_genome
    alt_flowcell_lanes = alt_lims_data.collect {|line| FlowcellLane.new line}
    @flowcell_lanes.each do |lane|
      alt_flowcell_lanes.each do |alt_lane|
        lane.equal(alt_lane).should_not == true
        alt_lane.equal(lane).should_not == true
      end
    end
  end
end
