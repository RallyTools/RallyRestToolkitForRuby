
#Custom headers
headers = RallyAPI::CustomHttpHeader.new()
headers.name    = "Company Name"
headers.vendor  = "Vendor Name"
headers.version = "Version client software"

# Config parameters
@config = {}
@config[:base_url]  = "https://trial.rallydev.com/slm"
@config[:username]  = "user@company.com"
@config[:password]  = "password"
@config[:api_key]   = "_Rd3...................................t8EU" # if present; this overrides un/pw
@config[:workspace] = "Workspace"
@config[:project]   = "Project"
@config[:version]   = "v2.0"
@config[:headers]   = headers

if FileTest.exist?( './MyVars.rb' )
    require './MyVars.rb'
end
