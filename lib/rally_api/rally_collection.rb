# :stopdoc:
#Copyright (c) 2002-2015 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:

module RallyAPI

  class RallyCollection
    include Enumerable

    attr_reader :results
    alias :values :results

    def initialize(results)
      @results = results
    end

    def [](index)
      if (index.kind_of? Fixnum)
        @results[index]
      else
        all = @results.find_all { |object| object.name == index }
        all.length == 1 ? all[0] : all
      end
    end

    def each(&block)
      # check for parameters method so we don't blow up on Ruby 1.8.7
      if (block.respond_to?('parameters') && block.parameters.length == 2)
        @results.each do |record|
          block.call(record.to_s, record)
        end
      else
        @results.each &block
      end
    end
    alias :each_value :each

    def size
      length
    end

    def length
      @results.count
    end

    def include?(name)
      self[name.to_s] != []
    end

    def empty?
      length == 0
    end

    def push(item)
      item = RallyObject.new(@rally_rest, item) if item.is_a?(Hash)
      @results.push(item)
    end

    def <<(item)
      push(item)
    end

  end

end
