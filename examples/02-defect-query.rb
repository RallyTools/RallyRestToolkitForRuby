#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00_config.rb
require_relative '00_config'

def show_results(title,results)
  puts "-"  * 80
  puts title
  puts ""
  results.each do |result|
    printf("%-30s %s \n",result.CreationDate, result.Name)
  end
  puts ""
  puts "Results Length : #{results.length}"
  puts "Total Results Count: #{results.total_result_count}"
end

begin
  rally_connection = RallyAPI::RallyRestJson.new(@config)

  #
  # Get the 10 most recent defects.
  #
  defect_query = RallyAPI::RallyQuery.new()
  defect_query.type = "defect"
  defect_query.fetch = "Name,CreationDate"
  defect_query.limit      = 10          #optional - default is 99999
  defect_query.page_size  = 10
  defect_query.project_scope_up = false
  defect_query.project_scope_down = true
  defect_query.order = "CreationDate Desc"

  results = rally_connection.find(defect_query)
  show_results("10 Most Recent Defects",results)

  #
  # Get defects created in the last 24 hours.
  #
  defect_query = RallyAPI::RallyQuery.new()
  start_date = Time.now - (86400*1)

  defect_query.query_string = "(CreationDate > #{start_date.iso8601})"
  defect_query.type = "defect"
  defect_query.fetch = "Name,CreationDate"
  defect_query.project_scope_up = false
  defect_query.project_scope_down = true
  defect_query.order = "CreationDate Desc"

  results = rally_connection.find(defect_query)
  show_results("Defects created In The Last 24 Hours",results)

rescue Exception=>boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

