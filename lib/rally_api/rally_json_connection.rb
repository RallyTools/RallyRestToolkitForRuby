require "httpclient"
require 'json'

# :stopdoc:
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:

module RallyAPI

  class RallyJsonConnection

    DEFAULT_PAGE_SIZE = 200

    attr_accessor :rally_headers, :low_debug, :logger
    attr_reader :find_threads, :rally_http_client

    def initialize(headers, low_debug, proxy_info)
      @rally_headers = headers
      @low_debug = low_debug
      @logger = nil

      @rally_http_client = HTTPClient.new
      @rally_http_client.cookie_manager = nil       #leaving this off unitl JSESSION/ZESSSIONID settles down
      @rally_http_client.receive_timeout = 300
      @rally_http_client.send_timeout    = 300
      @rally_http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @rally_http_client.transparent_gzip_decompression = true

      #passed in proxy setup overrides env level proxy
      env_proxy = ENV["http_proxy"]
      if (!env_proxy.nil?) && (proxy_info.nil?)
        @rally_http_client.proxy = env_proxy
      end
      @rally_http_client.proxy = proxy_info unless proxy_info.nil?

      @find_threads = 4
    end

    def set_client_user(base_url, user, password)
      @rally_http_client.set_basic_auth(base_url, user, password)
    end

    def set_ssl_verify_mode(mode = OpenSSL::SSL::VERIFY_NONE)
      @rally_http_client.ssl_config.verify_mode = mode
    end

    #you can have any number you want as long as it is between 1 and 4
    def set_find_threads(num_threads = 2)
      return if num_threads.class != Fixnum
      num_threads = 4 if num_threads > 4
      num_threads = 1 if num_threads < 1
      @find_threads = num_threads
    end

    def get_all_json_results(url, args, query_params, limit = 99999)
      all_results = []
      args[:method] = :get
      params = {}
      params[:pagesize] = query_params[:pagesize] || DEFAULT_PAGE_SIZE
      params[:start]    = 1
      params = params.merge(query_params)

      #query_result = send_json_request(url, args, params)
      query_result = send_request(url, args, params)
      all_results.concat(query_result["QueryResult"]["Results"])
      totals = query_result["QueryResult"]["TotalResultCount"]

      limit < totals ? stop = limit : stop = totals
      page = params[:pagesize] + 1
      page_num = 2
      query_array = []
      page.step(stop, params[:pagesize]) do |new_page|
        params[:start] = new_page
        query_array.push({:page_num => page_num, :url => url, :args => args, :params => params.dup})
        page_num = page_num + 1
      end

      all_res = []
      all_res = run_threads(query_array) if query_array.length > 0
      #stitch results back together in order
      all_res.each { |page_res| all_results.concat(page_res[:results]["QueryResult"]["Results"]) }

      query_result["QueryResult"]["Results"] = all_results
      query_result
    end

    #args should have :method
    def send_request(url, args, url_params = nil)
      method = args[:method]
      req_args = {}
      req_args[:query] = url_params unless url_params.nil?

      req_headers = @rally_headers.headers
      if (args[:method] == :post) || (args[:method] == :put)
        req_headers["Content-Type"] = "application/json"
        req_headers["Accept"] = "application/json"
        text_json =args[:payload].to_json
        req_args[:body] = text_json
      end
      req_args[:header] = req_headers

      begin
        log_info("Rally API calling #{method} - #{url} with #{req_args}")
        response = @rally_http_client.request(method, url, req_args)
      rescue Exception => ex
        msg =  "RallyAPI: - rescued exception - #{ex.message} on request to #{url} with params #{url_params}"
        log_info(msg)
        raise StandardError, msg
      end

      log_info("RallyAPI response was - #{response.inspect}")
      if response.status_code != 200
        msg = "RallyAPI - An issue occurred (HTTP-#{response.status_code}) on request - #{url}."
        msg << "\nResponse was: #{response.body}"
        raise StandardError, msg
      end

      json_obj = JSON.parse(response.body)   #todo handle null post error
      errs = check_for_errors(json_obj)
      raise StandardError, "\nError on request - #{url} - \n#{errs}" if errs[:errors].length > 0
      json_obj
    end

    private

    def run_threads(query_array)
      num_threads = @find_threads
      thr_queries = []
      (0...num_threads).each { |ind| thr_queries[ind] = [] }
      query_array.each { |query| thr_queries[query[:page_num] % num_threads].push(query) }

      thr_array = []
      thr_queries.each { |thr_query_array| thr_array.push(run_single_thread(thr_query_array)) }

      all_results = []
      thr_array.each do |thr|
        thr.value.each { |result_val| all_results.push(result_val) }
      end
      all_results.sort! { |resa, resb| resa[:page_num] <=> resb[:page_num] }
    end

    def run_single_thread(request_array)
      Thread.new do
        thread_results = []
        request_array.each do |req|
            page_res = send_request(req[:url], req[:args], req[:params])
            thread_results.push({:page_num => req[:page_num], :results => page_res})
        end
        thread_results
      end
    end

    def log_info(message)
      return unless @low_debug
      puts message if @logger.nil?
      @logger.debug(message) unless @logger.nil?
    end

    def check_for_errors(result)
      errors = []
      warnings = []
      if !result["OperationResult"].nil?
        errors    = result["OperationResult"]["Errors"]
        warnings  = result["OperationResult"]["Warnings"]
      elsif !result["QueryResult"].nil?
        errors    = result["QueryResult"]["Errors"]
        warnings  = result["QueryResult"]["Warnings"]
      elsif !result["CreateResult"].nil?
        errors    = result["CreateResult"]["Errors"]
        warnings  = result["CreateResult"]["Warnings"]
      end
      {:errors => errors, :warnings => warnings}
    end

  end


end
