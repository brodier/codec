module Codec
  class Prefixedlength < Base
    def initialize(id,length,content)
      # TODO : Check that value_codec has a null length attribute
      @length_codec = length
      @value_codec = content
      @id = id
    end
	
    def get_length(length_field)
    	length_field.get_value.to_i
    end
	
    def decode(buffer)
      l, buf = @length_codec.decode(buffer)
	    len = get_length(l)
	    if len == 0
	      f = Field.new
		    f.set_id(@id)
		    f.set_value(nil)
		    return f,buf
	    else
	      begin
		      f,remain = @value_codec.decode_with_length(buf,len)
		    rescue => e
		      Logger.error "Error in #{@id} decoder \n #{e.message}\n#{e.backtrace.join(10.chr)}"
		      raise ParsingException, e.message
		    end
        
        f.set_id(@id)
        return f,remain
	    end
    end
	
	  def build_field
	    begin
	      f,r = decode(@data)
	    rescue ErrorBufferUnderflow => e
	      raise ParsingException, e.message
	    end
	    # log error if r != ""
	    return f
	  end
    
    def encode(field)
      val = @value_codec.encode(field)
      length = @length_codec.encode(Field.new.set_value(val.length))
      out = length + val
      return out
    end
  end

  class Headerlength < Prefixedlength
    def initialize(id,header,content,length_path)
      @path = length_path # length attribute contain the path for length field in header
      @separator = @path.slice!(0).chr # first character contain the separator
      super(id,header,content)
    end
	
	  def get_length(header_field)
      return header_field.get_value.to_i if @path.length == 0 # Handle simple numeric header field
	  	length_field = header_field.get_deep_field(@path,@separator)
	  	if length_field.nil?
	  	  return 0
	  	else
	  	  length_field.get_value.to_i
	  	end
	  end

	  def decode(buffer)
	    f = Field.new
	    f.set_id(@id)
	    head, buf = @length_codec.decode(buffer)
	    head.set_id(@length_codec.id)
	    f.add_sub_field(head)
	    len = get_length(head)
	    if len == 0
	      return f,buf
	    else
        len -= (buffer.length - buf.length) if @header_length_include
	      val,remain = @value_codec.decode_with_length(buf,len)
        val.set_id(@value_codec.id)
	  	  f.add_sub_field(val)
        return f,remain
	    end
	  end
  end  

  class Headerfulllength < Headerlength
    def initialize(id,header,content,length_path)
      super(id,header,content,length_path)
    end
  end
  
end