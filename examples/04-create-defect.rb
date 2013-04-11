#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

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

  fields = {}
  fields["Name"] = "Test Defect created at #{Time.now.utc()} with Rally API gem"
  fields["Priority"] = "High Attention"

  new_defect = rally_connection.create("defect", fields)
  show_some_values("New Defect Fields", new_defect)

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

