require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally Json Create Tests" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
  end

  it "should create an object from a basic hash with ref" do
    obj = {}
    obj["Name"] = "Test Defect created #{DateTime.now()}"

    new_de = @rally.create(:defect, obj)
    new_de.Name.should == obj["Name"]
  end

  it "should throw an exception for a create on a bad artifact type" do
    obj = {}
    obj["Name"] = "Test Defect created #{DateTime.now()}"

    lambda { @rally.create(:bucky, obj) }.should raise_exception(StandardError, /Error on request/)
  end

  it "should create with a reference to another Object" do
    obj = {}
    obj["Name"] = "Test with a link to Owner"
    obj["Owner"] = @rally.user

    new_de = @rally.create(:defect, obj)
    new_de.Name.should == obj["Name"]
    new_de.Owner["_ref"].should == @rally.user["_ref"]
  end

  it "should raise an error on create if a field is required" do
    obj = {}
    obj["Name"] = ""

    lambda { @rally.create(:defect, obj) }.should raise_exception(/Error on request -/)
  end

  it "should create an object and delete it" do
    obj = {}
    obj["Name"] = "Test Defect created #{DateTime.now()}"

    new_de = @rally.create(:defect, obj)
    new_de.Name.should == obj["Name"]
    delete_result = new_de.delete()
    lambda { new_de.read }.should raise_exception(/Error on request -/)
  end

  it "should create with params to rank to bottom" do
    defect_hash = {"Name" => "Test Defect bottom ranked - created #{DateTime.now()}"}
    defect_hash["Severity"] = "Major Problem"
    params = {:rankTo => "BOTTOM"}
    new_defect = @rally.create(:defect, defect_hash, params)
    new_defect.Severity.should == "Major Problem"
    bottom_defects = @rally.find do |q|
      q.type = :defect
      q.order = "Rank Desc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    bottom_defects[0]["ObjectID"].should == new_defect["ObjectID"]
  end

end
