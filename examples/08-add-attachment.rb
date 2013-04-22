#! /usr/bin/env ruby

require 'pp'
require 'base64'

require 'rally_api'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'

jpg_file_name = "earthjello.jpeg"
jpg_file_path =  File::join(File.dirname(__FILE__),jpg_file_name)


def show_some_values(title, defect)
  values = ["Name", "CreationDate", "FormattedID","Attachments"]
  format = "%-12s : %s"

  puts "-" * 80
  puts title
  values.each do |field_name|
    if defect[field_name].class == RallyAPI::RallyCollection
      puts format % [field_name," "]
      defect[field_name].each do |value|
        puts format % [" ",value._refObjectName]
      end
    else
      puts format % [field_name, defect[field_name]]
    end
  end
end

def create_content(rally, content_string)
  begin
    content_base64 = Base64.encode64(content_string)
    content_ref = rally.create(:attachmentcontent, {"Content" => content_base64})
    return content_ref
  rescue Exception => boom
    puts "*" * 80
    puts "Exception rescued in create_content:"
    puts "Exception: #{boom.class}"
    puts "Error Message: #{boom}"
    raise StandardError, 'create_content failure'
  end

end


def post_text_attachment(rally, artifact, file_name, text_content)
  begin
    content = create_content(rally, text_content)

    attachment_info = {}
    attachment_info["Name"] = file_name
    attachment_info["ContentType"] = "text/plain"
    attachment_info["Size"] = text_content.length
    attachment_info["Content"] = content
    attachment_info["Artifact"] = artifact.ref

    result = rally.create(:attachment, attachment_info)

  rescue Exception => boom
    puts "*" * 80
    puts "Exception rescued in post_text_attachment"
    puts "Exception: #{boom.class}"
    puts "Error Message: #{boom}"
    raise StandardError, 'post_text_attachment failure'
  end
end

def post_jpg_attachment(rally, artifact, file_name, file_path)
  begin

    image_data = File.open(file_path, 'rb') { |f| f.read }

    content = create_content(rally, image_data)

    attachment_info = {}
    attachment_info["Name"] = file_name
    attachment_info["ContentType"] = "image/jpeg"
    attachment_info["Size"] = image_data.length
    attachment_info["Content"] = content
    attachment_info["Artifact"] = artifact.ref

    result = rally.create(:attachment, attachment_info)

  rescue Exception => boom
    puts "*" * 80
    puts "Exception rescued in post_jpg_attachment"
    puts "Exception: #{boom.class}"
    puts "Error Message: #{boom}"
    raise StandardError, 'post_text_attachment failure'
  end
end


begin
  rally = RallyAPI::RallyRestJson.new(@config)

  fields = {}
  fields["Name"] = "Test Defect with attachment created at #{Time.now.utc()} with Rally API gem"
  fields["Priority"] = "High Attention"

  new_defect = rally.create("defect", fields)
  show_some_values("Defect Fields", new_defect)

  post_text_attachment(rally, new_defect, "FirstAttachment.txt", "Attachment text for #{new_defect["FormattedID"]}")
  post_jpg_attachment(rally, new_defect, jpg_file_name, jpg_file_path)


  new_defect.read()
  show_some_values("Defect Fields with Attachments",new_defect)

rescue Exception => boom
  puts "*" * 80
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

