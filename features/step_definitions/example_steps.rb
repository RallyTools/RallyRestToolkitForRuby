
Given(/^that "(.*?)" exists in the examples directory$/) do |arg1|
  true
end


Given(/^a config file "([^"]*)"$/) do |config_file|
  headers = RallyAPI::CustomHttpHeader.new()
  headers.name    = "Leather Pants"
  headers.vendor  = "Rally"
  headers.version = "1.0"

# Config parameters
  @config = {}
  @config[:base_url]  = "https://trial.rallydev.com/slm"
  @config[:username]  = "yeti@rallydev.com"
  @config[:password]  = "RallyDev"
  @config[:workspace] = "JIRA 5.2 Testing"
  @config[:project]   = "Sample Project"
  @config[:version]   = "1.42"
  @config[:headers]   = headers
end

When(/^I create RallyRestJson$/) do
  @rally = RallyAPI::RallyRestJson.new(@config)
end

Then(/^I should see the Rally API version number of "([^"]*)"$/) do |version|
  version.should == RallyAPI::VERSION
end