module Codec
  
  class NilField
    def nil? ; return true; end
    def empty? ; return true; end
    def get_id ; "" ; end
    def get_value ; "" ;end
    def get_sf_recursivly id ; return self ; end
  end
  
  class Field
    def initialize(id="*",value="")
      @id = (id.nil? ? "*" : id)
      @value = value
    end
    
    def empty?
      return true if @value == ""
    end
    
    def self.from_array(id,fields_array)
      f = Field.new(id,fields_array)  
      return f
    end
    
    def ==(other)
      (@id == other.id && @value == other.value)
    end
    
    def eql?(other)
      self == other
    end
    
    def hash
      @id.hash ^ @value.hash
    end
    
    def get_id ; @id; end
    
    def set_id id ; @id = id ; end
    
    def get_value 
      if @value.kind_of?(Array)
        v = []
        @value.each{|id,value|
          v << Field.new(id,value)
        }
        return v
      else
        return @value
      end
    end
    
    def set_value(value,path = nil,separator =".")
      if path.nil?
  	    raise "Error can not set value that is instance of Array" if value.kind_of? Array
        @value = value
      else
        @value = set_node(@value,value,path.split(separator))
      end
      return self
    end
    
    def add_sub_field(sf)
      @value = [] if @value == ""
	    raise "Add impossible on not Array valued field" unless @value.kind_of? Array
	    @value << [sf.id,sf.value]
    end
    
	  def get_sf_recursivly(ids)
	  	if(ids.size == 1 && @value.kind_of?(Array))
	  		return get_sub_field(ids.first)
	  	elsif (ids.size > 1 && @value.kind_of?(Array))
	  		id = ids.slice!(0)
	  		return get_sub_field(id).get_sf_recursivly(ids)
	  	else
	  		return NilField.new
	  	end
	  end
	  
    def search(path,separator='.')
      get_sf_recursivly(path.split(separator))
    end
    
	  def get_deep_field(path,separator='.')
	  	get_sf_recursivly(path.split(separator))
	  end
    
    def set_node(value,new_value,path_ids)
      is_set = false
      value = value.collect{|id,val|
        if id != path_ids.first
         [id,val]
        else
          is_set = true
          if path_ids.size == 1
            [id,new_value]
          else
            [id,set_node(val,new_value,path_ids.slice(1,path_ids.size))]
          end
        end
      }
      unless is_set
        if path_ids.size == 1
          value << [path_ids.first,new_value]
        else
          value << [path_ids.first,set_node_rec([],new_value,
            path_ids.slice(1,path_ids.size))]
        end
      end
      return value      
    end
    
    def set_deep_field(sf,path,separator='.')
      @value = set_node(@value,sf.value,path.split(separator))
      self
    end
	  
    def get_sub_field(id)
	    sf_rec = get_sub_fields(id)
	    if sf_rec.nil?
	      return NilField.new
	    elsif sf_rec.size > 1
	      raise MultipleFieldError 
	    else 
	  	  return sf_rec.first
	    end
    end

    def get_sub_fields(id)
	    raise "Error No Subfield" unless @value.kind_of? Array
	    sf_rec = @value.select{|v| v.first == id}.collect{|v| v.last}
      if sf_rec == []
        return NilField.new
      elsif sf_rec.size == 1
        return [Field.new(id,sf_rec.first)]
      else 
        sfs = []
        sf_rec.each{|v| sfs << Field.new(id,v)}
        return sfs
      end
    end

   attr_reader :id,:value   
  end
end
