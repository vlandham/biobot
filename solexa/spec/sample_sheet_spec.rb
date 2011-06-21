
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SampleSheet do
  before(:each) do
    @bad_path = File.join(Paths.root_path, "#{INVALID_FLOWCELL}", Paths.basecalls_path, "SampleSheet.csv")
    @path = Dir.glob(File.join(Paths.root_path, "*#{VALID_FLOWCELL}", Paths.basecalls_path, "SampleSheet.csv"))[0]
  end
  it "should raise error on invalid path" do
    #s = SampleSheet.new(@bad_path).should raise_error
  end

  it "should not raise error on valid path" do
    ss = SampleSheet.new(@path)
  end

  it "should validate good sample sheet" do
    ss = SampleSheet.new(@path)
    ss.valid?.should == true
  end

  it "should invalidate bad sample sheet" do
    ss = SampleSheet.new(@path)
    ss.valid?.should == true
    ss.valid?.should_not == false
    good_lanes = ss.lanes
    ss.lanes[0]["SampleID"] = nil
    ss.valid?.should == false
  end

  it "should read sample sheet data" do
    ss = SampleSheet.new @path
    ss.lanes.size.should == 16
    ss.lanes.each do |lane|
      lane.size.should == 10
    end
  end
end
