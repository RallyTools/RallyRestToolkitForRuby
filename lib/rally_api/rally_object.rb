# :stopdoc:
#Copyright (c) 2002-2012 Rally Software Development Corp. All Rights Reserved.
#Your use of this Software is governed by the terms and conditions
#of the applicable Subscription Agreement between your company and
#Rally Software Development Corp.
# :startdoc:

module RallyAPI

  # RallyObject is a helper class that wraps the JSON.parsed hash
  #
  class RallyObject

    attr_reader :rally_object, :type

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
      get_val('Name') || get_val('_refObjectName')
    end

    def to_json(*args)
      rally_object.to_json
    end

    def [](field_name)
      get_val(field_name.to_s)
    end

    def []=(field_name, value)
      return if field_name.nil?
      rally_object[field_name.to_s] = value
    end

    def read(params = {})
      @rally_object = @rally_rest.reread(rally_object, params)
      self
    end
    alias :refresh :read

    def getref
      ref
    end

    def ref
      rally_object["_ref"]
    end

    def camel_case_word(sym)
      RallyAPI::RallyRestJson.camel_case_word(sym)
    end

    def elements
      @rally_object.inject({}) do |elements, (key, value)|
        if key.to_s.starts_with?("c_")
          key = key.to_s[2..-1]
        end
        elements[underscore(key).to_sym] = value
        elements
      end
    end

    def oid
      object_i_d
    end

    def username
      user_name || login_name
    end

    def password
      @rally_rest.rally_password
    end

    def ==(object)
      object.equal?(self) ||
          (object.instance_of?(self.class) &&
              object.ref == ref)
    end

    def eql?(object)
      self == (object)
    end

    def <=>(object)
      self.ref <=> object.ref
    end

    def hash
      self.ref.hash
    end

    def name
      get_val('Name') || get_val('_refObjectName')
    end

    def to_q
      @rally_object["_ref"]
    end

    def rank_above(relative_rally_object)
      @rally_object = @rally_rest.rank_above(rally_object["_ref"],relative_rally_object["_ref"]).rally_object
      self
    end

    def rank_below(relative_rally_object)
      @rally_object = @rally_rest.rank_below(rally_object["_ref"],relative_rally_object["_ref"]).rally_object
      self
    end

    def rank_to_bottom
      @rally_object = @rally_rest.rank_to(rally_object["_ref"], "BOTTOM").rally_object
      self
    end

    def rank_to_top
      @rally_object = @rally_rest.rank_to(rally_object["_ref"], "TOP").rally_object
      self
    end

    def delete()
      @rally_rest.delete(rally_object["_ref"])
    end

    private

    # An attempt to be rally_rest_api user friendly -
    # you can get a field the old way with an underscored field name or the upcase name
    def method_missing(sym, *args)
      ret_val = get_val(sym.to_s)
      if @rally_rest.rally_rest_api_compat && ret_val.nil?
        ret_val = get_val(camel_case_word(sym))
      end
      ret_val
    end

    #def get_val(field)
    #  return_val = rally_object[field]
    #
    #  if return_val.class == Hash
    #    return RallyObject.new(@rally_rest, return_val)
    #  end
    #
    #  if return_val.class == Array
    #    make_object_array(field)
    #    return_val = rally_object[field]
    #  end
    #
    #  return_val
    #end

    def get_val(field)
      return_val = @rally_object[field]
      return_val = @rally_object["c_#{field}"] if return_val.nil?

      if return_val.class == Hash
        if return_val.has_key?("_ref")
          return read_association return_val
        end
        return RallyObject.new(@rally_rest, return_val)
      end

      if return_val.class == Array
        make_object_array(field)
        return_val = @rally_object[field]
      end

      return_val
    end

    def read_association(object_or_collection)
      return read_collection(object_or_collection) if object_or_collection.has_key? 'Count'
      return RallyObject.new(@rally_rest, @rally_rest.reread(object_or_collection)) if @rally_rest.rally_rest_api_compat
      RallyObject.new(@rally_rest, object_or_collection)
    end

    def read_collection(collection)
      results = @rally_rest.reread(collection)["Results"]
      RallyCollection.new(results.collect { |object| RallyObject.new(@rally_rest, object) })
    end

    def underscore(camel_cased_word)
      camel_cased_word.split(/(?=[A-Z])/).join('_').downcase
    end

    def make_object_array(field)
      object_array = []
      rally_object[field].each do |rally_obj|
        object_array.push(RallyObject.new(@rally_rest, rally_obj))
      end
      rally_object[field] = object_array
    end

  end

end

