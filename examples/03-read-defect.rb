#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00_config.rb
require_relative '00_config'

def show_some_values(title, defect)
  values = ["Name", "CreationDate", "FormattedID", "Priority"]
  format = "%-12s : %s"

  puts "-" * 80
  puts title
  values.each do |field_name|
    puts format % [field_name, defect[field_name]]
  end
end

begin
  rally_connection = RallyAPI::RallyRestJson.new(@config)

  #
  # Get the 10 most recent defects.
  #
  defect_query = RallyAPI::RallyQuery.new()
  defect_query.type = "defect"
  defect_query.fetch = "Name,CreationDate"
  defect_query.limit = 10 #optional - default is 99999
  defect_query.page_size = 10
  defect_query.project_scope_up = false
  defect_query.project_scope_down = true
  defect_query.order = "CreationDate Desc"

  results = rally_connection.find(defect_query)

  first_defect = results.first
  show_some_values("Defect from query where fetch of fields Name and CreationDate", first_defect)

  first_defect.read()
  show_some_values("Defect after read: All fields now available.", first_defect)

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

