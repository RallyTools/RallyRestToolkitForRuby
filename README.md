## License

Copyright (c) 2002-2013 Rally Software Development Corp. All Rights Reserved.  Your use of this Software is governed by the terms and conditions of the applicable Subscription Agreement between your company and Rally Software Development Corp.

## Warranty

The Rally REST API for .NET is available on an as-is basis. 

## Support

Rally Software does not actively maintain this toolkit.  If you have a question or problem, we recommend posting it to Stack Overflow: http://stackoverflow.com/questions/ask?tags=rally 

## Introduction

RallyAPI (rally_api) -- a wrapper for Rally's REST Web Services API  

[![Stories in Ready](http://badge.waffle.io/RallyTools/RallyRestToolkitForRuby.png)](http://waffle.io/RallyTools/RallyRestToolkitForRuby)

RallyAPI is a wrapper of Rally's Web Service API Json endpoints using rest-client and native json parsing
Check the examples directory for more detailed samples.

### Installation

gem install rally_api

### Usage

Making a connection to Rally
    require 'rally_api'

    #Setting custom headers
    headers = RallyAPI::CustomHttpHeader.new()
    headers.name = "My Utility"
    headers.vendor = "MyCompany"
    headers.version = "1.0"

    #or one line custom header
    headers = RallyAPI::CustomHttpHeader.new({:vendor => "Vendor", :name => "Custom Name", :version => "1.0"})

    config = {:base_url => "https://rally1.rallydev.com/slm"}
    config[:username]   = "user@company.com"
    config[:password]   = "password"
    config[:workspace]  = "Workspace Name"
    config[:project]    = "Project Name"
    config[:headers]    = headers #from RallyAPI::CustomHttpHeader.new()

    @rally = RallyAPI::RallyRestJson.new(config)


### Querying Rally

    #type names are stored in rally.rally_objects hash, you can inspect there for a list
    #Look at the TypePath for all typedefs and this is the key to each hash.
    #If you pass in a symbol (for code using versions prior to 0.7.3), it will be downcased and turned into a string
    # examples are:   "defect", "hierarchicalrequirement", "portfolioitem/feature"

    test_query = RallyAPI::RallyQuery.new()
    test_query.type = "defect"
    test_query.fetch = "Name"
    test_query.workspace = {"_ref" => "https://rally1.rallydev.com/slm/webservice/1.25/workspace/12345.js" } #optional
    test_query.project = {"_ref" => "https://rally1.rallydev.com/slm/webservice/1.25/project/12345.js" }     #optional
    test_query.page_size = 200       #optional - default is 200
    test_query.limit = 1000          #optional - default is 99999
    test_query.project_scope_up = false
    test_query.project_scope_down = true
    test_query.order = "Name Asc"
    test_query.query_string = "(Severity = \"High\")"

    results = @rally.find(test_query)

    #tip - set the fetch string of the query to the fields you need -
    #only resort to the read method if you want your code to be slow
    results.each do |defect|
      puts defect.Name   # or defect["Name"]
      defect.read    #read the whole defect from Rally to get all fields (eg Severity)
      puts defect.Severity
    end

    #for people comfortable passing around blocks:
    results = @rally.find do |q|
        q.type = "defect"
        q.fetch = "Name,FormattedID"
        q.query_string = "(Priority = \"Low\")"
    end


### Reading an Artifact
    defect = @rally.read("defect", 12345)      #by ObjectID
    #or
    defect = @rally.read("defect", "FormattedID|DE42")      #by FormattedID
    #or if you already have an object like from a query
    results = @rally.find(RallyAPI::RallyQuery.new({:type => :defect, :query_string => "(FormattedID = DE42)"}))
    defect = results.first
    defect.read

    puts defect["Name"]
    #or - fields can be read by bracket artifact["FieldDisplayName"] or artifact.FieldDisplayName
    puts defect.Name

    #An Important note about reading fields and fetching:
    #If you query with a specific fetch string, for example query defect and fetch Name,Severity,Description
    #You will *only* get back those fields defect.Priority will be nil, but may not be null in Rally
    #Use object.read or @rally.read to make sure you read the whole object if you want what is in Rally
    #  This is done for speed - lazy loading (going back to get a value from Rally) can be unneccessarily slow
    #  *Pick you fetch strings wisely* fetch everything you need and don't rely on read if you don't need it the speed is worth it.

### Creating an Artifact
    obj = {}
    obj["Name"] = "Test Defect created #{DateTime.now()}"
    new_de = @rally.create("defect", obj)
    puts new_de["FormattedID"]

### Updating an Artifact
    fields = {}
    fields["Severity"] = "Critical"
    fields["Description"] = "Description for the issue"
    updated_defect = @rally.update("defect", 12345, fields)    #by ObjectID
    #or
    updated_defect = @rally.update("defect", "FormattedID|DE42", fields)   #by FormattedID
    # or
    defect = @rally.read("defect", 12345)      #by lookup then udpating via the object
    field_updates = {"Description" => "Changed Description"}
    defect.update(field_updates)

### Utils
    #allowed values:  pass the Artifact type string or downcased symbol and the Display Name of the field
    @rally.allowed_values("Defect", "Severity")
    @rally.allowed_values("story", "ScheduleState")

    #re-ranking:  rank_above and rank_below
    story1.rank_above(story2)   #in a drag and drop workspace move story1 relative to story2
    story1.rank_below(story2)
    story1.rank_to_bottom
    story1.rank_to_top

