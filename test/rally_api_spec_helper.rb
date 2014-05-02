require 'simplecov'

#clear simplecov filters so this works in Rubymine
SimpleCov.adapters.delete(:root_filter)
SimpleCov.filters.clear

SimpleCov.start do
  add_filter '/test/'
  add_filter '/.rvm/'
end

require 'yaml'
require_relative "../lib/rally_api"


# --- For spec helper - include a file named RallyAPIcredentials.txt in this directory and put this in it
#     put in your URL, user, password and workspace/project and the tests will run against those endpoints when needed
#     why no mocking?  I dont' always trust we get what we want from the wsapi, this helps get some confidence things
#     really are working as they should
#RallyURL:  https://trial.rallydev.com/slm
#Username:  user@company.com
#Password:  password
#Workspace: Workspace Name
#Project:   Project Name
#Debug:     false
#NonDefaultWS:  NonDefaultWorkspace
#CustomPIType:  CustomType
#WebLinkFieldName: CustomField

module RallyAPISpecHelper
  path = ""
  #cred_file = "RallyAPIcredentialsAPIKEY.txt"
  cred_file = "RallyAPIcredentials.txt"

  if (Dir.pwd.include?("test"))
    path = "./#{cred_file}"
  else
    path = "./test/#{cred_file}"
  end
  config = YAML.load_file(path)

  TEST_SETUP = {}
  TEST_SETUP[:base_url]  = config["RallyURL"]
  TEST_SETUP[:username]  = config["Username"]
  TEST_SETUP[:password]  = config["Password"]
  TEST_SETUP[:api_key]   = config["API_KEY"]
  TEST_SETUP[:workspace] = config["Workspace"]
  TEST_SETUP[:project]   = config["Project"]
  TEST_SETUP[:debug]     = config["Debug"]
  TEST_SETUP[:version]   = config["Version"]

  EXTRA_SETUP = {}
  EXTRA_SETUP[:nondefault_ws]  = config["NonDefaultWS"]
  EXTRA_SETUP[:custom_pi_type] = config["CustomPIType"]
  EXTRA_SETUP[:weblink_field_name] = config["WebLinkFieldName"]
end