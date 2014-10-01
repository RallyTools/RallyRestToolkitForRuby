require 'simplecov'
require 'yaml'
require 'rspec'
require 'pry'


#clear simplecov filters so this works in Rubymine
SimpleCov.profiles.delete(:root_filter)
SimpleCov.filters.clear
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/.rvm/'
end

# The lib directory must be loaded AFTER SimpleCov to enable code coverage metrics
require_relative "../lib/rally_api"


##############################
# Spec Configuration Files:
# This test suite assumes the existance of three config files in the spec/support/configs directory:
#    APIconfig_trial.txt         (currently the primary config file)
#    APIconfig_rally1.txt        (includes a valid API Key)
#    APIconfig_nondefaultws.yml  (includes extra keys for testing workspace scoping)
#
# These config files include authentication and workspace information.
# An example format for the APIconfig_trial.txt (formerly RallyAPIcredentials.txt) file is:
# RallyURL:  https://trial.rallydev.com/slm
# Username:  user@company.com
# Password:  password
# Workspace: Workspace Name
# Project:   Project Name
# Debug:     false
# NonDefaultWS:  NonDefaultWorkspace
# CustomPIType:  CustomType
# WebLinkFieldName: CustomField
##############################


### RallyConfigLoader::LoadConfig enables dynamic loading of config files
# Usage: Load Config File from spec
#   load config from default file: load_api_config
#   load config extras from default file: load_api_config_extras
#   load config from custom file:  load_api_config('YourConfigFile.txt')
module RallyConfigLoader
  class LoadConfig
    attr_accessor :test_setup, :extra_setup

    def initialize(config_name = nil)
      config_name ||= 'APIconfig_trial.txt'
      path = "./spec/support/configs/#{config_name}"
      config_file = YAML.load_file(path)

      @test_setup = {}
      @test_setup[:base_url]  = config_file["RallyURL"]
      @test_setup[:username]  = config_file["Username"]
      @test_setup[:password]  = config_file["Password"]
      @test_setup[:api_key]   = config_file["API_KEY"]
      @test_setup[:workspace] = config_file["Workspace"]
      @test_setup[:project]   = config_file["Project"]
      @test_setup[:debug]     = config_file["Debug"]
      @test_setup[:version]   = config_file["Version"]
      
      @extra_setup = {}
      @extra_setup[:nondefault_ws]  = config_file["NonDefaultWS"]
      @extra_setup[:custom_pi_type] = config_file["CustomPIType"]
      @extra_setup[:weblink_field_name] = config_file["WebLinkFieldName"]
    end
  end

  def load_api_config(config_name = nil)
    LoadConfig.new(config_name).test_setup
  end

  def load_api_config_extras(config_name = nil)
    LoadConfig.new(config_name).extra_setup
  end
end


RSpec.configure do |c|
  c.include(RallyConfigLoader)
  c.tty = true
  c.color = true
  c.formatter = :documentation
end