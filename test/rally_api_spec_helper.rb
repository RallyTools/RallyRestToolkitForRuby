require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require 'yaml'
require_relative "../lib/rally_api"

module RallyAPISpecHelper
  path = ""
  if (Dir.pwd.include?("test"))
    path = "./RallyAPIcredentials.txt"
  else
    path = "./test/RallyAPIcredentials.txt"
  end
  config = YAML.load_file(path)

  TEST_SETUP = {}
  TEST_SETUP[:base_url]  = config["RallyURL"]
  TEST_SETUP[:username]  = config["Username"]
  TEST_SETUP[:password]  = config["Password"]
  TEST_SETUP[:workspace] = config["Workspace"]
  TEST_SETUP[:project]   = config["Project"]
  TEST_SETUP[:debug]     = config["Debug"]
  #TEST_SETUP[:debug]     = true
end