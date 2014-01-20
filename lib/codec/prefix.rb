module Codec
  class Prefixedlength < Base
    def initialize(length,content)
      # TODO : Check that value_codec has a null length attribute
      @length_codec = length
      @value_codec = content
    end
	
    def get_length(length_field)
    	length_field.get_value.to_i
    end
	
    def decode(buffer, f, length=nil)
      Logger.warn {"Call decode with length on Prefixedlength codec should never happen"} unless length.nil?
      len_field = Field.new
      @length_codec.decode(buffer,len_field)
	    len = get_length(len_field)
	    if len == 0
		    f.set_value("")
	    else
	      begin
		      @value_codec.decode(buffer, f, len)
		    rescue => e
		      Logger.error "Error when decoding field #{f.get_id} \n #{e.message}\n#{e.backtrace.join(10.chr)}"
		      raise ParsingException.new e.message
		    end
	    end
    end
    
    def encode(buf, field)
      out = ""
      content_buf = ""
      len = @value_codec.encode(content_buf, field)
      @length_codec.encode(out, Field.new.set_value(len))
      out << content_buf
      buf << out
      return out.length
    end
  end

  class Headerlength < Prefixedlength
    def initialize(header,header_id,content,content_id,length_path,total_length = false)
      @header_id = header_id
      @content_id = content_id
      @path = length_path # length attribute contain the path for length field in header
      @separator = @path.slice!(0).chr # first character contain the separator
      @total_length = total_length # indicate that length in header is equal to (header + content) length
      super(header,content)
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
    
	  def decode(buffer, f, length=nil)
      buffer = buffer.slice!(0...length) if length && length > 0
      initial_len = buffer.size
      head = Field.new(@header_id)
      content = Field.new(@content_id)
	    @length_codec.decode(buffer,head)
      h_len = initial_len - buffer.size
	    f.add_sub_field(head)
	    len = get_length(head)
	    if len > 0
        len -= h_len if @total_length
	      @value_codec.decode(buffer, content, len)
	  	  f.add_sub_field(content)
	    end
	  end
    
    def encode(buf, field)
      # encode content
      content_buf = ""
      length = 0
      content = field.get_sub_field(@content_id)
      length  = @value_codec.encode(content_buf, content) unless content.nil?
      head = field.get_sub_field(@header_id)
      raise EncodingException.new "Missing header for encoding #{@id}" if head.empty?
      # update length field in header if length !=0
      head.set_value(length,@path,@separator) if length !=0
      # encode header
      head_buf =  ""
      h_len = @length_codec.encode(head_buf,head)
      # TODO : optimize computation for header length 
      if length != 0 && @total_length # re-encode header with total length
        length = head_buf.length + content_buf.length
        head.set_value(length,@path,@separator)
        head_buf = ""
        @length_codec.encode(head_buf,head)
      end
      buf << head_buf
      buf << content_buf
      return head_buf.length + content_buf.length
    end
  end  
  
  class Tagged < Base
    def initialize(tag_codec)
      @subCodecs = {}
      @tag_codec = tag_codec
    end

    def decode(buffer, field, length = nil)
      buffer = buffer.slice!(0...length) if length && length > 0
      tag = Field.new("TAG")
      @tag_codec.decode(buffer,tag)
      field.set_id(tag.get_value.to_s)
      if @subCodecs[tag.get_value.to_s].nil?
        raise ParsingException.new "Unknown tag #{tag.get_value.to_s} when decoding #{field.get_id}"
      end
      @subCodecs[tag.get_value.to_s].decode(buffer,field)
    end
    
    def encode(buffer, field)
      head = Field.new("tag", field.get_id)
      out = ""
      @tag_codec.encode(out, head)
      if @subCodecs[field.get_id].nil?
        raise EncodingException.new "Unknown tag #{field.get_id} for #{@id} encoder"
      end
      @subCodecs[field.get_id].encode(out, field)
      buffer << out
      return out.length
    end
  end
end
