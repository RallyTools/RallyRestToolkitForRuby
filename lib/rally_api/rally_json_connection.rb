require 'rest_client'
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

    attr_accessor :rally_headers, :retries, :retry_list

    def initialize(headers, low_debug, proxy_info)
      @rally_headers = headers
      @low_debug = low_debug
      @retries = 0
      @retry_list = {}

      if (!ENV["http_proxy"].nil?) && (proxy_info.nil?)
        RestClient.proxy = ENV['http_proxy']
      end

      if !proxy_info.nil?
        RestClient.proxy = proxy_info
      end

    end

    def read_object(url, args, params = nil)
      args[:method] = :get
      result = send_json_request(url, args, params)
      puts result if @low_debug
      rally_type = result.keys[0]
      result[rally_type]
    end

    def create_object(url, args, rally_object)
      args[:method] = :post
      text_json = rally_object.to_json
      args[:payload] = text_json
      puts "payload json: #{text_json}" if @low_debug
      result = send_json_request(url, args)
      puts result if @low_debug
      result["CreateResult"]["Object"]
    end

    def update_object(url, args, rally_fields)
      args[:method] = :post
      text_json = rally_fields.to_json
      args[:payload] = text_json
      puts "payload json: #{text_json}" if @low_debug
      result = send_json_request(url, args)
      puts result if @low_debug
      result["OperationResult"]
    end

    def put_object(url, args, put_params, rally_fields)
      args[:method] = :put
      text_json = rally_fields.to_json
      args[:payload] = text_json
      result = send_json_request(url, args, put_params)
      result["OperationResult"]
    end

    def delete_object(url,args)
      args[:method] = :delete
      result = send_json_request(url,args)
      puts result if @low_debug
      result["OperationResult"]
    end

    #---------------------------------------------
    def get_all_json_results(url, args, query_params, limit = 99999)
      all_results = []
      args[:method] = :get
      params = {}
      params[:pagesize] = query_params[:pagesize] || DEFAULT_PAGE_SIZE
      params[:start]    = 1
      params = params.merge(query_params)

      query_result = send_json_request(url, args, params)
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

    private

    def run_threads(query_array)
      num_threads = 4
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
            page_res = send_json_request(req[:url], req[:args], req[:params])
            thread_results.push({:page_num => req[:page_num], :results => page_res})
        end
        thread_results
      end
    end

    #todo support proxy stuff
    def send_json_request(url, args, url_params = nil)
      request_args = {}
      request_args[:url]      = url
      request_args[:user]     = args[:user]
      request_args[:password] = args[:password]
      request_args[:method]   = args[:method]
      request_args[:timeout]  = 120
      request_args[:open_timeout] = 120

      r_headers = @rally_headers.headers
      r_headers[:params] = url_params

      if (args[:method] == :post) || (args[:method] == :put)
        r_headers[:content_type] = :json
        r_headers[:accept] = :json
        request_args[:payload] = args[:payload]
      end

      request_args[:headers] = r_headers

      begin
        req = RestClient::Request.new(request_args)
        puts req.url if @low_debug
        response = req.execute
      rescue => ex
        msg =  "Rally Rest Json: - rescued exception - #{ex.message} on request to #{url} with params #{url_params}"
        puts msg
        if !@retry_list.has_key?(req.url)
          @retry_list[req.url] = 0
        end
        if (@retries > 0) && (retry_list[req.url] < @retries)
          @retry_list[req.url] += 1
          retry
        end
        raise StandardError, msg
      end
      @retry_list.delete(req.url)
      puts response if @low_debug
      json_obj = JSON.parse(response.body)   #todo handle null post error
      errs = check_for_errors(json_obj)
      raise StandardError, "\nError on request - #{url} - \n#{errs}" if errs[:errors].length > 0
      json_obj
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
