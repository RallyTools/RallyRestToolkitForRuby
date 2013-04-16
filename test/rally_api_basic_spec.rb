require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally Json API" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
  end

  it "should connect to Rally" do
    @rally.user.UserName.should_not be_nil
  end

  it "should properly allow aliases for types" do
    @rally.rally_alias_types["story"].should == "HierarchicalRequirement"
    an_alias = "myaliasfordefect"
    @rally.rally_alias_types[an_alias] = "Defect"
    @rally.rally_alias_types[an_alias].should == "Defect"
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
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
    my_logger = double("logger")
    my_logger.should_receive(:debug).at_least(:twice)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = true
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn off logger" do
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
    my_logger = double("logger")
    my_logger.should_not_receive(:debug)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = false
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn on logger discretely" do
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
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

  it "should let a client set the SSL verfiy mode" do
    verify_on =  OpenSSL::SSL::VERIFY_PEER
    verify_off = OpenSSL::SSL::VERIFY_NONE
    @rally.rally_connection.set_ssl_verify_mode(verify_on)
    @rally.rally_connection.rally_http_client.ssl_config.verify_mode.should == verify_on

    @rally.rally_connection.set_ssl_verify_mode(verify_off)
    @rally.rally_connection.rally_http_client.ssl_config.verify_mode.should == verify_off
  end

  it "should set the proxy info correctly" do
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
    proxy_setup = "http://puser:ppass@someproxy:3128"
    rally_config[:proxy] = proxy_setup
    errmsg1 = "RallyAPI: - rescued exception - getaddrinfo: nodename nor servname provided, or not known "
    errmsg2 = "http://someproxy:3128"
    lambda {RallyAPI::RallyRestJson.new(rally_config)}.should raise_error(StandardError, /#{errmsg1}.*#{errmsg2}/)
  end

  it "should throw a reasonable exception for a 404 URL" do
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
    rally_config[:base_url] = "https://trial.rallydev.com/slm/slm"
    lambda{RallyAPI::RallyRestJson.new(rally_config)}.should raise_error(StandardError, /RallyAPI - HTTP-404/)
  end

  it "should throw a reasonable exception for a bad password or username" do
    rally_config = RallyAPISpecHelper::TEST_SETUP.clone
    rally_config[:password] = "asdf"
    lambda{RallyAPI::RallyRestJson.new(rally_config)}.should raise_error(StandardError, /RallyAPI - HTTP-401/)
  end

end