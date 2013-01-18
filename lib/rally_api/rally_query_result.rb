# :stopdoc:
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:
module RallyAPI
  class RallyQueryResult
    include Enumerable

    attr_reader :results, :total_result_count

    def initialize(rally_rest, json_results)
      @results            = json_results["QueryResult"]["Results"]
      @total_result_count = json_results["QueryResult"]["TotalResultCount"]
      @rally_rest         = rally_rest
    end

    def each
      @results.each do |result|
        yield RallyObject.new(@rally_rest, result)
      end
    end

    def [](index)
      RallyObject.new(@rally_rest, @results[index])
    end

    def total_results
      @total_result_count
    end

    def length
      @results.length
    end

    def empty?
      length == 0
    end

    def results   #for compatiblity with code using rally_rest_api
      self
    end

  end
end
