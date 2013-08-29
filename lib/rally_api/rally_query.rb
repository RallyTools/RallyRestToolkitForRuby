# :stopdoc:
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:
module RallyAPI

# ===RallyAPI::RallyQuery - A helper class for making queries to Rally's REST API
# Example:
# new_query = RallyAPI::RallyQuery.new() and set query properties as needed
#   --- or ---
# new_query = RallyAPI::RallyQuery.new(query_hash) with a hash of attributes<br>
# query_hash for example can be:<br>
# query_hash = {}  <br>
# query_hash[:type] = Defect, Story, etc  <br>
# query_hash[:query_string] = "(State = \"Closed\")"   <br>
# query_hash[:fetch] = "Name,State,etc"  <br>
# query_hash[:workspace] = workspace json object or ref  #defaults to workspace passed in RallyRestJson.new if nil <br>
# query_hash[:project] = project json object or ref      #defaults to project passed in RallyRestJson.new if nil   <br>
# query_hash[:project_scope_up] = true/false    <br>
# query_hash[:project_scope_down] = true/false  <br>
# query_hash[:order] = "ObjectID asc" <br>
# query_hash[:page_size]  <br>
# query_hash[:limit]     <br>

  class RallyQuery
    attr_accessor :type, :query_string, :fetch, :workspace, :project, :project_scope_up, :project_scope_down, :search
    attr_accessor :order, :page_size, :limit

    alias :pagesize :page_size

    def initialize(query_hash = nil)
      parse_query_hash(query_hash) if !query_hash.nil?
      @page_size          = 200 if @page_size.nil?
      @limit              = 99999 if @limit.nil?
      @project_scope_up   = false if @project_scope_up.nil?
      @project_scope_down = false if @project_scope_down.nil?
      @page_size = @limit if @page_size > @limit
      self
    end

    def make_query_params
      query_params = {}
      query_params[:query]            = @query_string
      query_params[:fetch]            = @fetch
      query_params[:workspace]        = @workspace["_ref"] if !@workspace.nil?
      query_params[:project]          = @project["_ref"] if !@project.nil?
      query_params[:projectScopeUp]   = @project_scope_up
      query_params[:projectScopeDown] = @project_scope_down
      query_params[:order]            = @order
      query_params[:pagesize]         = @page_size
      query_params[:search]           = @search

      query_params
    end

    def validate()
      errors = []

      if @type.nil? || type == ""
        errors.push("Object type for query cannot be nil")
      end

      if @limit < 0
        errors.push("Stop after - #{@stop_after} - must be a number")
      end

      if @page_size < 0
        errors.push("Page size - #{@page_size} - must be a number")
      end

      if !@workspace.nil?
        errors.push("Workspace - #{@workspace} - must have a ref") if @workspace["_ref"].nil?
      end

      if !@project.nil?
        errors.push("Project - #{@project} - must have a ref") if @project["_ref"].nil?
      end

      errors
    end

    #support the crazy query string structure for the api
    #each condition with an and or an or needs to be wrapped rpn style in ()
    def build_query_segment(condition_array, op)
      return nil if condition_array.length == 0
      return condition_array.first if condition_array.length == 1

      op = op.downcase  #should be or or and

      query_segment = ""
      condition_array.each do |condition|
        q_part = "(#{condition})" if condition[0] != "("
        case op
          when 'or'
            query_segment = add_or(query_segment, q_part)
          when 'and'
            query_segment = add_and(query_segment, q_part)
          else
        end
      end

      return query_segment
    end

    def add_or(current_q, new_conditions)
      return current_q if (new_conditions.nil? || new_conditions.empty?)
      return new_conditions if (current_q.nil? || current_q.empty?)
      new_conditions = "(#{new_conditions})" if new_conditions[0] != "("
      "(#{current_q} OR #{new_conditions})"
    end

    def add_and(current_q, new_conditions)
      return current_q if new_conditions.nil? || new_conditions.empty?
      return new_conditions if current_q.nil? || current_q.empty?
      new_conditions = "(#{new_conditions})" if new_conditions[0] != "("
      "(#{current_q} AND #{new_conditions})"
    end

    private

    def parse_query_hash(query_hash)
      @type               = query_hash[:type].to_s
      @query_string       = query_hash[:query_string]
      @fetch              = query_hash[:fetch]
      @project_scope_down = query_hash[:project_scope_down]
      @project_scope_up   = query_hash[:project_scope_up]
      @order              = query_hash[:order]
      @page_size          = query_hash[:page_size]
      @limit              = query_hash[:limit]
      @workspace          = query_hash[:workspace]
      @project            = query_hash[:project]
    end

  end


end
