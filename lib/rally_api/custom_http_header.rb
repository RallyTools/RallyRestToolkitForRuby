#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.

require_relative "version"

#custom headers help Rally identify the integration you have written
#  You can make custom headers by:
#  ch = RallyAPI::CustomHttpHeader.new({:name => "CustomRoobyTool", :vendor => "acme inc", :version => "1.0"})
#  or by calling with no hash in the arguments and setting ch.name, ch.vendor, and ch.version
module RallyAPI

  class CustomHttpHeader
    attr_accessor :name, :version, :vendor
    attr_reader :library, :os, :platform

    HTTP_HEADER_FIELDS = [:name, :vendor, :version, :library, :platform, :os]
    HTTP_HEADER_PREFIX = 'X-RallyIntegration'

    def initialize(custom_vals = {})
      @os = RUBY_PLATFORM
      @platform = "Ruby #{RUBY_VERSION}"
      @library = "RallyRestJson version #{RallyAPI::VERSION}"
      @name = "RallyRestJsonRuby"

      if custom_vals.keys.length > 0
        @name    = custom_vals[:name]
        @version = custom_vals[:version]
        @vendor  = custom_vals[:vendor]
      end
    end

    def headers
      headers = {}
      HTTP_HEADER_FIELDS.each do |field|
        value = self.send(field)
        next if value.nil?
        header_key = "#{HTTP_HEADER_PREFIX}#{field.to_s.capitalize}"
        headers[header_key.to_sym] = value
      end
      headers
    end
  end

end

