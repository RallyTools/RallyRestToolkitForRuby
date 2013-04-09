

require 'rally_api'

#Custom headers
headers = RallyAPI::CustomHttpHeader.new()
headers.name    = "Leather Pants"
headers.vendor  = "Rally"
headers.version = "1.0"

# Config parameters
@config = {}
@config[:base_url]  = "https://trial.rallydev.com/slm"
@config[:username]  = "yeti@rallydev.com"
@config[:password]  = "RallyDev"
@config[:workspace] = "JIRA 5.2 Testing"
@config[:project]   = "Sample Project"
@config[:version]   = "1.42"
@config[:headers]   = headers

