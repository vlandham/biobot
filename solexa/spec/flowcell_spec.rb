require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/mock_lims')

describe Flowcell do
  describe "creation" do
    it "should raise with invalid path" do
      Flowcell.new(INVALID_FLOWCELL, MockLims::flowcell_lanes(INVALID_FLOWCELL)).should raise_error
    end

    it "should not raise with valid flowcell" do
      f = Flowcell.new(VALID_FLOWCELL, MockLims::flowcell_lanes(VALID_FLOWCELL))
      f.class.should == Flowcell
    end

  end

  describe "lanes" do
    it "should capture lane data" do
      f = Flowcell.new(VALID_FLOWCELL, MockLims::flowcell_lanes(VALID_FLOWCELL))
      f.lanes.size.should == 1
      f.each_lane do |lane|
        lane.organism.should == "mm9"
      end
    end
  end
end
