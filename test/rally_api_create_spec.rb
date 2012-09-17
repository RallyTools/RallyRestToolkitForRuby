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

    lambda { @rally.create(:bucky, obj) }.should raise_exception(/The object type bucky is not valid/)
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

  it "should be able to create a PI post 1.37" do
    pi_types = @rally.find do |q|
      q.type = :typedefinition
      q.query_string = '(Parent.Name = "Portfolio Item")'
      q.limit = 10
      q.fetch = "Name"
    end

    name_to_try = nil
    pi_types.each do |typ|
      next if typ.Name == "Portfolio Item"
      name_to_try = typ.Name
    end

    fields = {:Name => "test #{name_to_try} for rally_api - #{DateTime.now}"}
    new_pi = @rally.create(name_to_try.downcase.gsub(" ", "").to_sym, fields)
    new_pi.should_not be_nil
    new_pi.Name.should == fields[:Name]
  end

end
