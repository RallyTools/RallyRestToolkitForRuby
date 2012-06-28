require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require 'yaml'
require_relative "../lib/rally_api"


# --- For spec helper - include a file named RallyAPIcredentials.txt in this directory and put this in it
#     put in your URL, user, password and workspace/project and the tests will run against those enpoints when needed
#     why no mocking?  I dont' always trust we get what we want from the wsapi, this helps get some confidence things
#     really are working as they should
#RallyURL:  https://trial.rallydev.com/slm
#Username:  user@company.com
#Password:  apassword
#Workspace: Workspace Name
#Project:   Project Name
#Debug:     false

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