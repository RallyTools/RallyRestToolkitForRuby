#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

begin
  rally_connection = RallyAPI::RallyRestJson.new(@config)

  puts "rally_api version : #{RallyAPI::VERSION}"
  puts "Rally Web Services API version: #{rally_connection.wsapi_version}"

rescue Exception=>boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end


