# :stopdoc:
#Copyright (c) 2002-2015 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:

module RallyAPI
    # query is like:
    # query_hash = {}
    # query_hash["find"] = { some json for a query} or true
    # query_hash["fields"] = ["State", "PlanEstimate"]
    # query_hash["pagesize"] = 1000
    # query_hash["sort"] = { _id: 1 }
    # query_hash["workspace"] = workspace oid for query uri

  #query info is the master hash instead of a bunch of instance variables
  class LookbackAPIQuery
    attr_accessor :query_info

    def initialize(query_hash = nil)
      @query_info = nil
      parse_query_hash(query_hash) if !query_hash.nil?
      self
    end

    def make_query_params
      query_params = {}
      query_params[:find]      = @query_string
      query_params[:workspace]  = @workspace["_ref"] if !@workspace.nil?
      query

      query_params
    end

    def validate(allowed_objects)
      errors = []

      if @type.nil?
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

      if (allowed_objects[@type].nil?)
        errors.push( "Object Type #{@type} is not query-able: inspect RallyRestJson.rally_objects for allowed types" )
      end

      errors
    end

    private

    def parse_query_hash(query_hash)
      #@type               = query_hash[:type]
      #@query_string       = query_hash[:query_string]
      #@fetch              = query_hash[:fetch]
      #@project_scope_down = query_hash[:project_scope_down]
      #@project_scope_up   = query_hash[:project_scope_up]
      #@order              = query_hash[:order]
      #@page_size          = query_hash[:page_size]
      #@stop_after         = query_hash[:limit]
      @workspace      = query_hash[:workspace]
      #@project        = query_hash[:project]
    end

  end


end
