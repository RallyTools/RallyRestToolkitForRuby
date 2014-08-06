require 'simplecov'
require 'yaml'
require 'rspec'
require_relative "../lib/rally_api"


#clear simplecov filters so this works in Rubymine
SimpleCov.adapters.delete(:root_filter)
SimpleCov.filters.clear
SimpleCov.start do
  add_filter '/test/'
  add_filter '/.rvm/'
end


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

# TODO: Deprecate in favor of new RallyConfigLoader class and load_api_config helper method
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

  class TestSetup
    attr_accessor :test_setup, :extra_setup

    def initialize(config_file = 'RallyAPIcredentials.txt')
      @cred_file = config_file

      if (Dir.pwd.include?("test"))
        path = "./#{@cred_file}"
      else
        path = "./test/#{@cred_file}"
      end
      config = YAML.load_file(path)

      @test_setup = {}
      @test_setup[:base_url]  = config["RallyURL"]
      @test_setup[:username]  = config["Username"]
      @test_setup[:password]  = config["Password"]
      @test_setup[:api_key]   = config["API_KEY"]
      @test_setup[:workspace] = config["Workspace"]
      @test_setup[:project]   = config["Project"]
      @test_setup[:debug]     = config["Debug"]
      @test_setup[:version]   = config["Version"]

      @extra_setup = {}
      @extra_setup[:nondefault_ws]  = config["NonDefaultWS"]
      @extra_setup[:custom_pi_type] = config["CustomPIType"]
      @extra_setup[:weblink_field_name] = config["WebLinkFieldName"]

      return @test_setup
    end

  end
end

### New setup enables dynamic loading of config files
# Usage: Load Config File
#   load config from default file: load_api_config.test_setup
#   load config from custom file:  load_api_config('YourConfigFile.txt').test_setup

module RallyConfigLoader
  class LoadConfig
    attr_accessor :test_setup, :extra_setup

    def initialize(config_file = 'RallyAPIcredentials.txt')
      @cred_file = config_file

      if (Dir.pwd.include?("test"))
        path = "./#{@cred_file}"
      else
        path = "./test/#{@cred_file}"
      end
      config_file = YAML.load_file(path)
      
      @extra_setup = {}
      @extra_setup[:nondefault_ws]  = config_file["NonDefaultWS"]
      @extra_setup[:custom_pi_type] = config_file["CustomPIType"]
      @extra_setup[:weblink_field_name] = config_file["WebLinkFieldName"]

      @test_setup = {}
      @test_setup[:base_url]  = config_file["RallyURL"]
      @test_setup[:username]  = config_file["Username"]
      @test_setup[:password]  = config_file["Password"]
      @test_setup[:api_key]   = config_file["API_KEY"]
      @test_setup[:workspace] = config_file["Workspace"]
      @test_setup[:project]   = config_file["Project"]
      @test_setup[:debug]     = config_file["Debug"]
      @test_setup[:version]   = config_file["Version"]
    end

  end

  def load_api_config(config_file = 'RallyAPIcredentials.txt')
    LoadConfig.new(config_file)
  end
end

RSpec.configure do |c|
  c.include(RallyConfigLoader)
end