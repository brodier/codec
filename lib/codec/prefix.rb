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
	
	  def build_field(buf,length)
	    begin
	      f,r = decode(buf[0,length])
	    rescue ErrorBufferUnderflow => e
	      raise ParsingException, e.message
	    end
	    Logger.error "Error remain data in Prefixedlength" if r != ""
	    return f
	  end
    
    def encode(field)
      l, val = @value_codec.encode_with_length(field)
      length = @length_codec.encode(Field.new.set_value(l))
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
    
    def encode(field)
      # encode content
      content_field = field.get_sub_field(@value_codec.id)
      length, content = @value_codec.encode_with_length(content_field)
      head_field = field.get_sub_field(@length_codec.id)
      raise EncodingException, "Missing header for encoding #{@id}" if head_field.empty?
      # update length field in header if length !=0
      head_field.set_value(length,@path,@separator) if length !=0
      # encode header
      header =  @length_codec.encode(head_field)
      return header + content
    end
  end  

  class Headerfulllength < Headerlength
    # TODO : to implement
  end
  
  class Tagged < Base
    def initialize(id,tag_codec)
      @subCodecs = {}
      @tag_codec = tag_codec
	    @id = id
    end
    
    def decode(buffer)
      tag,buf = @tag_codec.decode(buffer)
      if @subCodecs[tag.get_value.to_s].nil?
        raise ParsingException, "Unknown tag #{tag.get_value.to_s} for #{@id} decoder"
      end
      f,buf = @subCodecs[tag.get_value.to_s].decode(buf)
      f.set_id(tag.get_value.to_s)
      return f,buf
    end
    
    def encode(field)
      head = Field.new(@tag_codec.id, field.get_id)
      out = @tag_codec.encode(head)
      if @subCodecs[field.get_id].nil?
        raise EncodingException, "Unknown tag #{field.get_id} for #{@id} encoder"
      end
      out += @subCodecs[field.get_id].encode(field)
      return out
    end
  end
end
