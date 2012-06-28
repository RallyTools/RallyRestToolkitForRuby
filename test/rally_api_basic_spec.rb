require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally Json API" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
  end

  it "should connect to Rally" do
    @rally.user.UserName.should_not be_nil
  end

  it "should have a list of cached object names" do
    @rally.rally_objects[:hierarchicalrequirement].should == "Hierarchical Requirement"
    @rally.rally_objects[:defect]. should == "Defect"
    @rally.rally_objects[:portfolioitem].should == "Portfolio Item"
    @rally.rally_objects[:type].should == "Type"
  end

  it "should have a default workspace and project" do
    @rally.rally_default_workspace.nil?.should == false
    @rally.rally_default_project.nil?.should == false
    @rally.rally_default_project.Name.should_not be_nil
    @rally.rally_default_workspace.Name.should_not be_nil
  end

  it "should get the reference fields okay" do
    RallyAPI::RALLY_REF_FIELDS.nil?.should == false
    RallyAPI::RALLY_REF_FIELDS.include?("foo").should == false
    RallyAPI::RALLY_REF_FIELDS.include?("Parent").should == true
    RallyAPI::RALLY_REF_FIELDS.include?("Requirement").should == true
    RallyAPI::RALLY_REF_FIELDS.include?("WorkProduct").should == true
  end

end