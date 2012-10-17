require "rspec"
require_relative "rally_api_spec_helper"
require_relative "../lib/rally_api/custom_http_header"

describe "Rally Custom Headers" do

  it "should have the basic information" do
    ch = RallyAPI::CustomHttpHeader.new()
    ch.name.should == "RallyRestJsonRuby"
    ch.platform.should match("Ruby")
    ch.library.should match("RallyRestJson version")
  end

  it "should generate headers properly" do
    ch = RallyAPI::CustomHttpHeader.new()
    headers = ch.headers

    #puts headers
    headers[:"X-RallyIntegrationName"].should == "RallyRestJsonRuby"
    headers[:"X-RallyIntegrationPlatform"].should match("Ruby")
  end

  it "should generate headers properly with customized info" do
    ch = RallyAPI::CustomHttpHeader.new()
    ch.name = "Custom Name"
    ch.vendor = "Vendor2"

    headers = ch.headers

    headers[:"X-RallyIntegrationName"].should == "Custom Name"
    headers[:"X-RallyIntegrationPlatform"].should match("Ruby")
    headers[:"X-RallyIntegrationVendor"].should == "Vendor2"
  end

  it "should generate headers properly with customized info" do
    ch = RallyAPI::CustomHttpHeader.new({:vendor => "Vendor", :name => "Custom Name", :version => "2.0"})
    headers = ch.headers

    headers[:"X-RallyIntegrationName"].should == "Custom Name"
    headers[:"X-RallyIntegrationPlatform"].should match("Ruby")
    headers[:"X-RallyIntegrationVendor"].should == "Vendor"
    headers[:"X-RallyIntegrationVersion"].should == "2.0"
  end

  it "should have basic headers with a new up of RallyJsonApi" do
    rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
    rally.rally_headers.name.should match("Rally")
  end


end