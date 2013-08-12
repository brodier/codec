module Codec
  
  class NilField
    def nil? ; return true; end
    def get_id ; "" ; end
    def get_value ; "" ;end
    def get_sf_recursivly id ; return self ; end
  end
  
  class Field
    def initialize(id="*")
      @id = (id.nil? ? "*" : id)
      @value = ""
    end

    def get_id ; @id; end
    
    def set_id id ; @id = id ; end
    
    def get_value ; @value; end
    
    def set_value(value)
	    raise "Error can not set value that is instance of Array" if value.kind_of? Array
      @value = value
      return self
    end
    
    def add_sub_field(sf)
      @value = [] if @value == ""
	    raise "Add impossible on not Array valued field" unless @value.kind_of? Array
	    @value << [sf.get_id,sf]
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
	  
	  def get_deep_field(path,separator='.')
	  	get_sf_recursivly(path.split(separator))
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
      else
        return sf_rec
      end
    end
  
   def to_yaml(tab="")
     if @value.kind_of? Array
	     s = tab + @id +": \n" 
	     tab += "  "
	     @value.each{|v|
	       s += v.last.to_yaml(tab)
	     }
	     return s
	   else
	     tab + @id + ": " + @value.to_s + "\n"
	   end
   end   
  end
end
