#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

def show_results(title,results)
  puts "-"  * 80
  puts title
  puts ""
  format = "%-30s :  %-30s : %-30s : %s\n"
  printf(format,"User Name","Email Address","Display Name","Reference")
  puts ""
  results.each do |result|
    printf(format,result.UserName, result.EmailAddress, result.DisplayName,result._ref)
  end
  puts ""
end

begin
  rally = RallyAPI::RallyRestJson.new(@config)

  user_query = RallyAPI::RallyQuery.new()
  user_query.query_string = "(UserName = #{@config[:username]})"
  user_query.type = "user"
  user_query.fetch = "UserName,EmailAddress,DisplayName"

  results = rally.find(user_query)
  show_results(user_query.query_string,results)

  user_query.query_string = "(Disabled = false)"

  results = rally.find(user_query)
  show_results(user_query.query_string,results)

rescue Exception=>boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

