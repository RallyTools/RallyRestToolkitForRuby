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

## 01-connect-to-rally.rb
This is just a simple script to test that a connection to
rally subscription credentions defined in 00-config.rb are correct.


