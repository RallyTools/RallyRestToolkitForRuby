# :stopdoc:
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:

module RallyAPI

  #todo add rankTo bottom and top
  #https://trial.rallydev.com/slm/webservice/x/defect/oid.js?rankTo=BOTTOM
  #https://trial.rallydev.com/slm/webservice/x/defect/oid.js?rankTo=TOP

  # RallyObject is a helper class that wraps the JSON.parsed hash
  #
  class RallyObject

    attr_reader :rally_object

    def initialize(rally_rest, json_hash)
      @type = json_hash["_type"] || json_hash["_ref"].split("/")[-2]
      @rally_object = json_hash
      @rally_rest = rally_rest
    end

    def update(fields)
      oid = @rally_object["ObjectID"] || @rally_object["_ref"].split("/")[-1].split(".")[0]
      @rally_object = @rally_rest.update(@type.downcase.to_sym, oid, fields).rally_object
    end

    def to_s(*args)
      @rally_object.to_json
    end

    def to_json(*args)
      @rally_object.to_json
    end

    def [](field_name)
      get_val(field_name)
    end

    def read(params = nil)
      @rally_object = @rally_rest.reread(@rally_object, params)
      self
    end

    def getref
      ref
    end

    def ref
      @rally_object["_ref"]
    end

    def rank_above(relative_rally_object)
      @rally_rest.rank_above(@rally_object["_ref"],relative_rally_object["_ref"])
    end

    def rank_below(relative_rally_object)
      @rally_rest.rank_below(@rally_object["_ref"],relative_rally_object["_ref"])
    end

    def delete()
      @rally_rest.delete(@rally_object["_ref"])
    end

    private

    # An attempt to be rally_rest_api user friendly -
    # you can get a field the old way with an underscored field name or the upcase name
    def method_missing(sym, *args)
      ret_val = get_val(sym.to_s)
      if @rally_rest.rally_rest_api_compat && ret_val.nil?
        ret_val = get_val(camel_case_word(:sym))
      end
      ret_val
    end

    def get_val(field)
      return_val = @rally_object[field]

      if return_val.class == Hash
        return RallyObject.new(@rally_rest, return_val)
      end

      if return_val.class == Array
        make_object_array(field)
        return_val = @rally_object[field]
      end

      return_val
    end

    def make_object_array(field)
      object_array = []
      @rally_object[field].each do |rally_obj|
        object_array.push(RallyObject.new(@rally_rest, rally_obj))
      end
      @rally_object[field] = object_array
    end

    #taken from rally_rest_api - to try to help with backwards compatibility
    def camel_case_word(sym)
        sym.to_s.split("_").map { |word| word.capitalize }.join
    end

  end

end

