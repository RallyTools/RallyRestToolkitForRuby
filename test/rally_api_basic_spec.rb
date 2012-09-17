require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally Json API" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
  end

  it "should connect to Rally" do
    @rally.user.UserName.should_not be_nil
  end

  #note - in wsapi 1.37 and above, we now have PI split out in dynatypes - prior to that, they aren't there
  it "should have a list of cached object names" do
    @rally.rally_objects[:hierarchicalrequirement].should == "HierarchicalRequirement"
    @rally.rally_objects[:defect]. should == "Defect"
    @rally.rally_objects[:portfolioitem].should == "PortfolioItem" unless @rally.wsapi_version.split(".")[1].to_i < 37
    @rally.rally_objects[:requirement].should == "Requirement"
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

  it "should take a logger on create" do
    rally_config = RallyAPISpecHelper::TEST_SETUP
    my_logger = double("logger")
    my_logger.should_receive(:debug).at_least(:twice)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = true
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn off logger" do
    rally_config = RallyAPISpecHelper::TEST_SETUP
    my_logger = double("logger")
    my_logger.should_not_receive(:debug)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = false
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn on logger discretely" do
    rally_config = RallyAPISpecHelper::TEST_SETUP
    my_logger = double("logger")
    my_logger.should_receive(:debug).exactly(2).times
    rally_config[:logger] = my_logger
    rally_config[:debug]  = false
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
    test_rally.debug_logging_on
    test_rally.find do |q|
      q.type = :defect
      q.limit = 200
      q.query_string = "(ObjectID < 1)"
    end
  end

end