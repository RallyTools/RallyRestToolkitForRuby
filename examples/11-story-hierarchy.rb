#! /usr/bin/env ruby

require 'rally_api'
require 'pp'

#Configuration for rally connection specified in 00-config.rb
require_relative '00-config'


class RallyRunner
  
  def initialize(config)
    @rally = RallyAPI::RallyRestJson.new(config)

    @fields = {}
    @fields["Priority"]    = "High Attention"
  end

  def empty_project()
    list = @rally.find do |q|
      q.type  = "defect"
      q.fetch = false
      q.limit = 1000
    end
    puts "deleting #{list.length} defects"
    list.each { |item| item.delete}

    list = @rally.find do |q|
      q.type  = "story"
      q.fetch = true
      q.limit = 1000
    end
    puts "deleting #{list.length} defects"
    list.each do |item|
      if item["Parent"].nil?
        puts "deleting #{item["Name"]}"
        item.delete
      end
    end
  end

  def find_defect(id)
    list = @rally.find do |q|
      q.type = "defect"
      q.query_string = "( ObjectID = #{id} )"
      q.fetch = true
      q.limit = 10
    end
    list.first
  end

  def find_story(id)
    list = @rally.find do |q|
      q.type = "story"
      q.query_string = "( ObjectID = #{id} )"
      q.fetch = true
      q.limit = 10
    end
    list.first
  end

  def show_some_values(defect,title)
    values = ["Name","ObjectID","FormattedID","Description"]
    format = "%-12s : %s"
    puts "-" * 80
    puts title
    values.each do |field_name|
      puts format % [field_name, defect[field_name]]
    end
  end

  def new_story(number_of_stories)
    story_ids = []
    number_of_stories.times do  | story_index |
      name  = "Story %04d" % [story_index]
      puts name
      @fields["Name"]        = name
      @fields["Description"] = "Story index %d created at #{Time.now}" % [story_index]
      story = @rally.create("story", @fields)
      story_ids << story["ObjectID"]
    end
    return story_ids
  end

  def new_child_stories(parent_id, number_of_stories)

    parent_story =  find_story(parent_id)

    parent_name = parent_story["Name"]

    number_of_stories.times do | child_index |
      name = "%s %04d" % [parent_name,child_index]
      puts name
      @fields["Name"]        = name
      @fields["Description"] = "Child index %d of parent %s created at #{Time.now}" % [child_index,parent_name]
      @fields["Parent"]      = parent_story
      story = @rally.create("story", @fields)
    end

  end

end



begin

  rally_runner = RallyRunner.new(@config)

  rally_runner.empty_project

  story_ids = rally_runner.new_story(3)

  story_ids.each do | story_id |
    rally_runner.new_child_stories(story_id,5)
  end

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end

