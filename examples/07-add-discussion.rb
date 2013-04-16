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

def post_discussion(rally, artifact, text)
  begin
    discussion_fields = {:Artifact => artifact, :Text => text}
    rally.create(:conversationpost, discussion_fields)
  rescue Exception => boom
    puts "Rescued in post_discussion: #{boom.class}"
    puts "Error Message: #{boom}"
    raise StandardError, "Could not post discussion: #{text}"
  end
end

def show_discussions(artifact)
  artifact.read
  discussions = artifact["Discussion"]

  if discussions.nil?
    puts "No discussions for #{artifact["FormattedID"]}"
  else
    puts "-" * 80
    puts "Discussions:"
    discussions.each do |disc|
      disc.read        # why not refresh ?
      puts ">" * 10
      puts disc["Text"]
    end
  end
end



begin
  rally = RallyAPI::RallyRestJson.new(@config)

  fields = {}
  fields["Name"] = "Test Defect with discussion created at #{Time.now.utc()} with Rally API gem"
  fields["Priority"] = "High Attention"

  new_defect = rally.create("defect", fields)
  show_some_values("New Defect Fields", new_defect)

  post_discussion(rally,new_defect,"First Discussion about defect #{new_defect["FormattedID"]}")
  post_discussion(rally,new_defect,"Second Discussion about defect #{new_defect["FormattedID"]}")

  show_discussions(new_defect)

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

