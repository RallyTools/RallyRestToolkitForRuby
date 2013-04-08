#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00_config.rb
require_relative '00_config'



puts "hello"

begin

  puts "rally_api version : #{RallyAPI::VERSION}"

  rally_connection = RallyAPI::RallyRestJson.new(@config)

rescue Exception=>boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

puts "goodbye"

