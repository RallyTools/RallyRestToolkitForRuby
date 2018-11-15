
#Custom headers
headers = RallyAPI::CustomHttpHeader.new()
headers.name    = "Company Name"
headers.vendor  = "Vendor Name"
headers.version = "Version client software"

# Config parameters
@config = {}
@config[:base_url]  = "https://trial.rallydev.com/slm"    # This is the default setting.
@config[:username]  = "user@company.com"
@config[:password]  = "password"
@config[:workspace] = "Workspace"
@config[:project]   = "Project"
@config[:version]   = "1.42"        # If not set, will use default version defined in gem.
@config[:headers]   = headers

require_relative 'MyVars.rb'
