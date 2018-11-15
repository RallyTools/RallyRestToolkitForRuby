#! /usr/bin/env ruby

require 'rally_api'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

def commatize(integer)
  return integer.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def show_results(title,results)
  puts title
  puts "-----------"
  h1 = '             Size          FormattedID  DisplayName  CreationDate              Name'
  h2 = '             ------------  -----------  -----------  ------------------------  ---------------------------------'
  puts h1,h2
  total_size = 0
  sorted = results.sort_by {|r| r.Size}
  sorted.each_with_index do |result,result_index|
    printf("[%4d/%4d]: %12s  %11s  %11s  %-24s  %s\n",
            result_index+1,
            results.length,
            commatize(result.Size.to_i),
            result.Artifact.FormattedID,
            result.User.DisplayName,
            result.CreationDate,
            result.Name
    )
    total_size += result.Size
  end
  puts h2,h1
  puts ""
  puts "Total Count: #{results.length}"
  puts "Total Sizes: #{commatize(total_size)} bytes"
end

begin
  rally = RallyAPI::RallyRestJson.new(@config)

  #
  # Get all attachments
  #
  query                     = RallyAPI::RallyQuery.new()
  query.type                = 'attachment'
  query.fetch               = 'Name,CreationDate,Size,Artifact,User,FormattedID,DisplayName'
  query.page_size           = 2000
  query.project_scope_up    = true
  query.project_scope_down  = true

  results = rally.find(query)
  show_results("All Attachemnts",results)

rescue Exception=>boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

#[the end]#
