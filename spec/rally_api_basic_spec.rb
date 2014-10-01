require_relative "spec_helper"

describe "Rally Json API" do

  before(:all)       { @rally = RallyAPI::RallyRestJson.new(load_api_config) }
  let(:rally_config) { load_api_config }

  it "should connect to Rally" do
    expect(@rally.user.UserName).not_to be_nil
  end

  it "should properly allow aliases for types" do
    expect(@rally.rally_alias_types["story"]).to eq("HierarchicalRequirement")
    an_alias = "myaliasfordefect"
    @rally.rally_alias_types[an_alias] = "Defect"
    expect(@rally.rally_alias_types[an_alias]).to eq("Defect")
  end

  it "should have a default workspace and project" do
    expect(@rally.rally_default_workspace.nil?).to eq(false)
    expect(@rally.rally_default_project.nil?).to eq(false)
    expect(@rally.rally_default_project.Name).not_to be_nil
    expect(@rally.rally_default_workspace.Name).not_to be_nil
  end

  it "should get the reference fields okay" do
    expect(RallyAPI::RALLY_REF_FIELDS.nil?).to eq(false)
    expect(RallyAPI::RALLY_REF_FIELDS.include?("foo")).to eq(false)
    expect(RallyAPI::RALLY_REF_FIELDS.include?("Parent")).to eq(true)
    expect(RallyAPI::RALLY_REF_FIELDS.include?("Requirement")).to eq(true)
    expect(RallyAPI::RALLY_REF_FIELDS.include?("WorkProduct")).to eq(true)
  end

  it "should take a logger on create" do
    my_logger = double("logger", :<< => nil)
    expect(my_logger).to receive(:debug).at_least(:twice)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = true
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn off logger" do
    my_logger = double("logger", :<< => nil)
    expect(my_logger).not_to receive(:debug)
    rally_config[:logger] = my_logger
    rally_config[:debug]  = false
    test_rally = RallyAPI::RallyRestJson.new(rally_config)
  end

  it "should turn on logger discretely" do
    my_logger = double("logger", :<< => nil)
    expect(my_logger).to receive(:debug).exactly(2).times
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
    expect(@rally.rally_connection.rally_http_client.ssl_config.verify_mode).to eq(verify_on)

    @rally.rally_connection.set_ssl_verify_mode(verify_off)
    expect(@rally.rally_connection.rally_http_client.ssl_config.verify_mode).to eq(verify_off)
  end

  it "should set the proxy info correctly" do
    proxy_setup = "http://puser:ppass@someproxy:3128"
    rally_config[:proxy] = proxy_setup
    error_msg = /RallyAPI: - rescued exception - getaddrinfo: .*(name|Name).* not known \(http:\/\/someproxy:3128\) on request to/
    expect {RallyAPI::RallyRestJson.new(rally_config)}.to raise_error(StandardError, error_msg)
  end

  it "should throw a reasonable exception for a 404 URL" do
    rally_config[:base_url] = "https://trial.rallydev.com/slm/slm"
    expect{RallyAPI::RallyRestJson.new(rally_config)}.to raise_error(StandardError, /RallyAPI - HTTP-302/)
  end

  it "should throw a reasonable exception for a bad password or username" do
    rally_config[:api_key] = nil
    rally_config[:password] = "asdf"
    expect{RallyAPI::RallyRestJson.new(rally_config)}.to raise_error(StandardError, /RallyAPI - HTTP-401/)
  end

end