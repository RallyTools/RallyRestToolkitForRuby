require_relative "spec_helper"


describe "Rally Custom Headers" do

  it "should have the basic information" do
    ch = RallyAPI::CustomHttpHeader.new()
    expect(ch.name).to eq("RallyRestJsonRuby")
    expect(ch.platform).to match("Ruby")
    expect(ch.library).to match("RallyRestJson version")
  end

  it "should generate headers properly" do
    ch = RallyAPI::CustomHttpHeader.new()
    headers = ch.headers

    #puts headers
    expect(headers[:"X-RallyIntegrationName"]).to eq("RallyRestJsonRuby")
    expect(headers[:"X-RallyIntegrationPlatform"]).to match("Ruby")
  end

  it "should generate headers properly with customized info" do
    ch = RallyAPI::CustomHttpHeader.new()
    ch.name = "Custom Name"
    ch.vendor = "Vendor2"

    headers = ch.headers

    expect(headers[:"X-RallyIntegrationName"]).to eq("Custom Name")
    expect(headers[:"X-RallyIntegrationPlatform"]).to match("Ruby")
    expect(headers[:"X-RallyIntegrationVendor"]).to eq("Vendor2")
  end

  it "should generate headers properly with customized info" do
    ch = RallyAPI::CustomHttpHeader.new({:vendor => "Vendor", :name => "Custom Name", :version => "2.0"})
    headers = ch.headers

    expect(headers[:"X-RallyIntegrationName"]).to eq("Custom Name")
    expect(headers[:"X-RallyIntegrationPlatform"]).to match("Ruby")
    expect(headers[:"X-RallyIntegrationVendor"]).to eq("Vendor")
    expect(headers[:"X-RallyIntegrationVersion"]).to eq("2.0")
  end

  it "should generate headers properly with only some of the customized info set" do
    ch = RallyAPI::CustomHttpHeader.new({:vendor => "Vendor"})
    headers = ch.headers

    expect(headers[:"X-RallyIntegrationName"]).to eq("RallyRestJsonRuby")
    expect(headers[:"X-RallyIntegrationVendor"]).to eq("Vendor")
    expect(headers[:"X-RallyIntegrationVersion"]).to be_nil

    ch = RallyAPI::CustomHttpHeader.new({:name => "Custom Name"})
    headers = ch.headers

    expect(headers[:"X-RallyIntegrationName"]).to eq("Custom Name")
    expect(headers[:"X-RallyIntegrationVendor"]).to be_nil
    expect(headers[:"X-RallyIntegrationVersion"]).to be_nil
  end


  it "should have basic headers with a new up of RallyJsonApi" do
    rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
    expect(rally.rally_headers.name).to match("Rally")
  end


end