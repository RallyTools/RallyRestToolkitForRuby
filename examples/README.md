# README for rally_api gem examples.

Complete documentation of the Rally web services api can be found at [here](https://rally1.rallydev.com/slm/doc/webservice/)


## 00-config.rb Setup
All of the scripts are configured with by requiring a file named 00-config.rb. The file
00-config.rb.template is a sample configure file.  Create a 00-config.rb by coping
00-config.rb.template :

```
cp 00-config.rb.template 00-config.rb
```

The template file looks like this:

```ruby

require 'rally_api'

#HTTP Custom headers
headers = RallyAPI::CustomHttpHeader.new()
headers.name    = "ACME Quality Test Harness"
headers.vendor  = "ACME Industries"
headers.version = "1.3.9"

# Config parameters
@config = {}
@config[:base_url]  = "https://rally1.rallydev.com/slm"
@config[:username]  = "tester@acme.com"
@config[:password]  = "acme_one"
@config[:workspace] = "ACME Widget Division"
@config[:project]   = "Test Results"
@config[:headers]   = headers

```

The optional HTTP custom headers are used to
understand usage patterns and improve Rally's products and APIs.

The 00-config.rb file is required by all example scripts. It
defines a @config hash used to create a RallyRestJson object.

## Basic Artifact Processing.

### 01-connect-to-rally.rb
This is just a simple script to test that a connection to a
rally subscription using the credentials defined in 00-config.rb
are correct.

The RallyRestJson object is the gateway to all communication to and from
Rally. It is used to query for rally artifacts and to create and update them
as well.  It can also be used to query workspaces, projects and users.

### 02-defect-query.rb
This example demonstrates two queries.  The first requests the 10 most recent defects created.
The second requests all defects created in the last 24 hours. The RallyRestJson.find method
returns an array of RallyObjects defined by the search conditions set by a RallyQuery. The RallyQuery
these search conditions .  Some of those attributes are:

#### type
There can only be one artifact type per query.  Examples of artifact types are defect and story.

#### fetch
The fetch attribute defines what fields will be return in the RallyObjects by the query to Rally.
The value of the fetch is a comma separated string of field names. The fields names
are the same as how they appear as in Rally, but with their spaces and underscores removed.
In the 02-defect-query.rb example the Creation Date field becomes CreationDate when
used in fetch.

#### query_string
The query_string attribute limits the results returned by the query.  In second query in 02-defect-query.rb the
query string limits the defects to those created in the last 24 hours.

### 03-read-defect.rb
The RallyObjects returned by RallyRestJson.find only contain the fields defined in
the fetch attribute of the RallyQuery object. To retrieve all of the fields of
an artifact use the read method.  03-read-defect.rb shows that only the Name and
Creation Date are set in RallyObjects are returned by find in this case.  After
the read method is called on a RallyObject all of an artifact's fields are now available.









