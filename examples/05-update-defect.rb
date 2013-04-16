#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

def show_some_values(title, defect)
  values = ["Name", "CreationDate", "FormattedID", "Priority","Description"]
  format = "%-12s : %s"

  puts "-" * 80
  puts title
  values.each do |field_name|
    puts format % [field_name, defect[field_name]]
  end

end


begin
  rally = RallyAPI::RallyRestJson.new(@config)

  fields = {}
  fields["Name"]        = "Test Defect created at #{Time.now.utc()} with Rally API gem"
  fields["Priority"]    = "High Attention"
  fields["Description"] = "The First description of the defect"

  new_defect = rally.create("defect", fields)
  show_some_values("New Defect Fields", new_defect)

  updated_fields = {"Description" => "The Updated description of the defect."}

  updated_defect = new_defect.update(updated_fields)

  show_some_values("Updated Defect Fields",updated_defect)

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

