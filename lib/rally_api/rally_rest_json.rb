require_relative "custom_http_header"
require_relative "rally_json_connection"
require_relative "rally_object"
require_relative "rally_query"
require_relative "rally_query_result"

# --
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# ++

#todo - raise exception if ws/project is not set on create?

#   -----
#   :title:RallyAPI
#
#   ===Getting Started
#   RallyAPI::RallyRestJson is the starting point for working in Ruby with Rally's REST WSAPI
#   config = {:base_url => "https://rally1.rallydev.com/slm"}
#   config[:username]   = "user@company.com"
#   config[:password]   = "password"
#   config[:workspace]  = "Workspace Name"
#   config[:project]    = "Project Name"
#   config[:headers]    = headers #from RallyAPI::CustomHttpHeader.new()
#   @rally = RallyAPI::RallyRestJson.new(config)


module RallyAPI

  #--
  #this contstant is here - a tradeoff of speed vs completeness- right now speed wins because it is so
  #expensive to query typedef and read all attributes for "OBJECT" or "COLLECTION" types
  #++
  RALLY_REF_FIELDS = { "Subscription" => :subscription, "Workspace" => :workspace, "Project" => :project,
                       "Iteration" => :iteration, "Release" => :release, "WorkProduct" => :artifact,
                       "Requirement" => :hierarchicalrequirement, "Owner" => :user, "Tester" => :user,
                       "RevisionHistory" => :revisionhistory, "Revision" => :revision, "Revisions" => :revision,
                       "Blocker" => :artifact, "SubmittedBy" => :user, "TestCaseResult" => :testcaseresult,
                       "TestSet" => :testset, "Parent" => :hierarchicalrequirement, "TestFolder"=> :testfolder,
                       "PortfolioItemType" => :type }


  #Main Class to instantiate when using the tool
  class RallyRestJson
    DEFAULT_WSAPI_VERSION = "1.37"

    attr_accessor :rally_url, :rally_user, :rally_password, :rally_workspace_name, :rally_project_name, :wsapi_version
    attr_accessor :rally_headers, :rally_default_workspace, :rally_default_project, :low_debug, :proxy_info
    attr_accessor :rally_rest_api_compat, :logger

    attr_reader   :rally_connection, :rally_objects

    def initialize(args)
      @rally_url            = args[:base_url] || "https://rally1.rallydev.com/slm"
      @rally_user           = args[:username]
      @rally_password       = args[:password]
      @rally_workspace_name = args[:workspace]
      @rally_project_name   = args[:project]
      @wsapi_version        = args[:version]  || DEFAULT_WSAPI_VERSION
      @rally_headers        = args[:headers]  || CustomHttpHeader.new
      @proxy_info           = args[:proxy]

      @rally_rest_api_compat  = args[:rally_rest_api_compat] || false

      @low_debug = args[:debug]  || false
      @logger    = args[:logger] || nil    #assumes this is an instance of Logger

      @rally_connection = RallyJsonConnection.new(@rally_headers, @low_debug, @proxy_info)
      @rally_connection.set_client_user(@rally_url, @rally_user, @rally_password)
      @rally_connection.logger  = @logger unless @logger.nil?

      @rally_objects = { "typedefinition" => "TypeDefinition", "user" => "User", "subscription" => "Subscription",
                         "workspace" => "Workspace", "project" => "Project" }

      if !@rally_workspace_name.nil?
        @rally_default_workspace = find_workspace(@rally_workspace_name)
        raise StandardError, "unable to find default workspace #{@rally_workspace_name}" if @rally_default_workspace.nil?
      end

      cache_rally_objects()

      if !@rally_project_name.nil?
        @rally_default_project = find_project(@rally_default_workspace, @rally_project_name)
        raise StandardError, "unable to find default project #{@rally_project_name}" if @rally_default_project.nil?
      end

      self
    end

    def debug_logging_on
      @low_debug = true
      @rally_connection.low_debug = true
    end

    def debug_logging_off
      @low_debug = false
      @rally_connection.low_debug = false
    end

    def find_workspace(workspace_name)
      sub = self.user["Subscription"].read({:fetch => "Workspaces,Name,State"})
      workspace = nil
      sub.Workspaces.each do |ws|
        #ws.read
        if (ws["Name"] == workspace_name) && (ws["State"] == "Open")
          workspace = ws
          break  #doing a break for performance some customers have 100+ workspaces - no need to do the others
        end
      end
      workspace
    end

    def find_project(workspace_object, project_name)
      if workspace_object.nil?
        raise StandardError, "A workspace must be provided to find a project"
      end

      query = RallyQuery.new()
      query.type          = :project
      query.query_string  = "((Name = \"#{project_name}\") AND (State = \"Open\"))"
      query.limit         = 20
      query.fetch         = true
      query.workspace     = workspace_object

      results = find(query)
      return results.first if results.length > 0
      nil
    end

    def user
      args = { :method => :get }
      json_response = @rally_connection.send_request(make_get_url(@rally_objects["user"]), args)
      rally_type = json_response.keys[0]
      RallyObject.new(self, json_response[rally_type])
    end


    def create(type, fields)
      rally_type = check_type(type)

      if (fields["Workspace"].nil? && fields["Project"].nil?)
        fields["Workspace"] = @rally_default_workspace._ref unless @rally_default_workspace.nil?
        fields["Project"] = @rally_default_project._ref unless @rally_default_project.nil?
      end

      object2create = { rally_type => make_ref_fields(fields) }
      args = { :method => :post, :payload => object2create }
      #json_response = @rally_connection.create_object(make_create_url(rally_type), args, object2create)
      json_response = @rally_connection.send_request(make_create_url(rally_type), args)
      #todo - check for warnings
      RallyObject.new(self, json_response["CreateResult"]["Object"]).read()
    end


    def read(type, obj_id, params = nil)
      rally_type = check_type(type)
      ref = check_id(rally_type, obj_id)
      args = { :method => :get }
      #json_response = @rally_connection.read_object(ref, args, params)
      json_response = @rally_connection.send_request(ref, args, params)
      rally_type = json_response.keys[0]
      RallyObject.new(self, json_response[rally_type])
    end

    def delete(ref_to_delete)
      args = { :method => :delete }
      #json_response = @rally_connection.delete_object(ref_to_delete, args)
      json_response = @rally_connection.send_request(ref_to_delete, args)
      json_response["OperationResult"]
    end

    def reread(json_object, params = nil)
      args = { :method => :get }
      #json_response = @rally_connection.read_object(json_object["_ref"], args, params)
      json_response = @rally_connection.send_request(json_object["_ref"], args, params)
      rally_type = json_response.keys[0]
      json_response[rally_type]
    end


    def update(type, obj_id, fields)
      rally_type = check_type(type)
      ref = check_id(rally_type, obj_id)
      json_update = { rally_type => make_ref_fields(fields) }
      args = { :method => :post, :payload => json_update }
      #json_response = @rally_connection.update_object(ref, args, json_update)
      json_response = @rally_connection.send_request(ref, args)
      #todo check for warnings on json_response["OperationResult"]
      RallyObject.new(self, reread({"_ref" => ref}))
    end

    ##-----
    #Querying Rally example
    #test_query = RallyAPI::RallyQuery.new()
    #test_query.type = :defect
    #test_query.fetch = "Name"
    #test_query.workspace = {"_ref" => "https://rally1.rallydev.com/slm/webservice/1.25/workspace/12345.js" } #optional
    #test_query.project = {"_ref" => "https://rally1.rallydev.com/slm/webservice/1.25/project/12345.js" }     #optional
    #test_query.page_size = 200       #optional - default is 200
    #test_query.limit = 1000          #optional - default is 99999
    #test_query.project_scope_up = false
    #test_query.project_scope_down = true
    #test_query.order = "Name Asc"
    #test_query.query_string = "(Severity = \"High\")"
    #
    #results = @rally.find(test_query)
    #
    ##tip - set the fetch string of the query to the fields you need -
    ##only resort to the read method if you want your code to be slow
    #results.each do |defect|
    #  puts defect.Name   # or defect["Name"]
    #  defect.read    #read the whole defect from Rally to get all fields (eg Severity)
    #  puts defect.Severity
    #end
    #query_obj is RallyQuery
    def find(query_obj = RallyQuery.new)
      yield query_obj if block_given?

      if query_obj.workspace.nil?
        query_obj.workspace = @rally_default_workspace unless @rally_default_workspace.nil?
      end

      errs = query_obj.validate(@rally_objects)
      if errs.length > 0
        raise StandardError, "Errors making Rally Query: #{errs.to_s}"
      end

      query_url = make_query_url(@rally_url, @wsapi_version, check_type(query_obj.type))
      query_params = query_obj.make_query_params
      args =  {:user => @rally_user, :password => @rally_password}
      json_response = @rally_connection.get_all_json_results(query_url, args, query_params, query_obj.limit)
      RallyQueryResult.new(self, json_response)
    end

    def adjust_find_threads(num_threads)
      @rally_connection.set_find_threads(num_threads)
    end

    #rankAbove=%2Fhierarchicalrequirement%2F4624552599
    #{"hierarchicalrequirement":{"_ref":"https://rally1.rallydev.com/slm/webservice/1.27/hierarchicalrequirement/4616818613.js"}}
    def rank_above(ref_to_rank, relative_ref)
      ref = ref_to_rank
      params = {}
      params[:rankAbove] = short_ref(relative_ref)
      params[:fetch] = "true"
      json_update = { get_type_from_ref(ref_to_rank) => {"_ref" => ref_to_rank} }
      args = { :method => :put, :payload => json_update }
      #update = @rally_connection.put_object(ref, args, params, json_update)
      update = @rally_connection.send_request(ref, args, params)
      RallyObject.new(self, update["OperationResult"]["Object"])
    end

    #ref to object.js? rankBelow=%2Fhierarchicalrequirement%2F4624552599
    def rank_below(ref_to_rank, relative_ref)
      ref = ref_to_rank
      params = {}
      params[:rankBelow] = short_ref(relative_ref)
      params[:fetch] = "true"
      json_update = { get_type_from_ref(ref_to_rank) => {"_ref" => ref_to_rank} }
      args = { :method => :put, :payload => json_update }
      update = @rally_connection.send_request(ref, args, params)
      RallyObject.new(self, update["OperationResult"]["Object"])
    end

    def rank_to(ref_to_rank, location = "TOP")
      ref = ref_to_rank
      params = {}
      params[:rankTo] = location
      params[:fetch]  = "true"
      json_update = { get_type_from_ref(ref_to_rank) => {"_ref" => ref_to_rank} }
      args = { :method => :put, :payload => json_update }
      update = @rally_connection.send_request(ref, args, params)
      RallyObject.new(self, update["OperationResult"]["Object"])
    end

    #todo - check support for portfolio item fields
    def allowed_values(type, field)
      if type.class == Symbol
        query_type = @rally_objects[type.to_s]
      else
        query_type = type
      end
      type_defs_query             = RallyQuery.new()
      type_defs_query.type        = "typedefinition"
      type_defs_query.fetch       = true
      type_defs_query.query_string= "(ElementName = \"#{query_type}\")"
      type_defs = find(type_defs_query)

      allowed_vals = {}
      type_defs[0]["Attributes"].each do |attr|
        next if attr["ElementName"] != field
        attr["AllowedValues"].each do |val_ref|
          val = val_ref["StringValue"]
          val = "Null" if val.nil? || val.empty?
          allowed_vals[val] = true
        end
      end
      allowed_vals
    end

    private

    def make_get_url(type)
      "#{@rally_url}/webservice/#{@wsapi_version}/#{type}.js"
    end

    def make_read_url(type,oid)
      "#{@rally_url}/webservice/#{@wsapi_version}/#{type}/#{oid}.js"
    end

    def make_create_url(type)
      "#{@rally_url}/webservice/#{@wsapi_version}/#{type}/create.js"
    end

    def make_query_url(rally_url, wsapi_version, type)
      "#{rally_url}/webservice/#{wsapi_version}/#{type}.js"
    end

    def short_ref(long_ref)
      ref_pieces = long_ref.split("/")
      "/#{ref_pieces[-2]}/#{ref_pieces[-1].split(".js")[0]}"
    end

    def check_type(type_name)
      type = @rally_objects[type_name.to_s]
      if type.nil?
        raise StandardError, "The object type #{type_name} is not valid for the wsapi"
      end
      type.gsub(" ", "")   #for wsapi no space is expected
    end

    #ref should be like https://rally1.rallydev.com/slm/webservice/1.25/defect/12345.js
    def has_ref?(json_object)
      if json_object["_ref"].nil?
        return false
      end
      return true if json_object["_ref"] =~ /^https:\/\/\S*(\/slm\/webservice)\S*.js$/
      false
    end

    #expecting idstring to have "FormattedID|DE45" or the objectID
    def check_id(type, idstring)
      if idstring.class == Fixnum
        return make_read_url(type, idstring)
      end

      if (idstring.class == String) && (idstring.index("FormattedID") == 0)
        return ref_by_formatted_id(type, idstring.split("|")[1])
      end
      make_read_url(type, idstring)
    end

    def ref_by_formatted_id(type, fid)
      query = RallyQuery.new()
      query.type          = type.downcase
      query.query_string  = "(FormattedID = #{fid})"
      query.limit         = 20
      query.fetch         = "FormattedID"
      query.workspace     = @rally_default_workspace

      results = find(query)
      return results.first["_ref"] if results.length > 0
      nil
    end

    #eg https://rally1.rallydev.com/slm/webservice/1.25/defect/12345.js
    def get_type_from_ref(ref)
      ref.split("/")[-2]
    end

    def make_ref_fields(fields)
      fields.each do |key,val|
        if (val.class == RallyObject)
          fields[key] = val.getref
        end
      end
      fields
    end

    def cache_rally_objects()
      type_defs_query = RallyQuery.new()
      type_defs_query.type = "typedefinition"
      type_defs_query.fetch = "Name,Parent,ElementName,TypePath"
      type_defs_query.workspace = @rally_default_workspace unless @rally_default_workspace.nil?

      type_defs = find(type_defs_query)
      type_defs.each do |td|
        url_path = td.TypePath.nil? ? td.ElementName : td.TypePath
        @rally_objects[url_path.downcase] = url_path

        parent_type = td.Parent
        if !parent_type.nil? && (@rally_objects[parent_type.TypePath].nil?)
          url_path = parent_type.TypePath.nil? ? parent_type.ElementName : parent_type.TypePath
          @rally_objects[url_path.downcase] = url_path
        end
      end

      #some convenience keys to help people - someday we'll fix the api and make HR called story
      @rally_objects["useriterationcapacity"]  = "User Iteration Capacity"
      @rally_objects["userpermission"]         = "User Permission"
      @rally_objects["story"]                  = "Hierarchical Requirement"
      @rally_objects["userstory"]              = "Hierarchical Requirement"
    end

  end

end
