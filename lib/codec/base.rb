module Codec
  class Base
    attr_reader :id
    def initialize(id,length)
        @length = length.to_i
        @id = id
    end

    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(buf[0,length])
      return f
    end
    
    def decode_with_length(buf,length)
      l = eval_length(buf,length)
      return build_field(buf,l),buf[l,buf.length]
    end
    
    def decode(buf)
      l = eval_length(buf,@length)
      return build_field(buf,l),buf[l,buf.length]
    end    

    def encode(field)
      return field.get_value
    end
    
    def encode_with_length(field)
      buf = encode(field)
      return buf.length, buf
    end
    
    def get_length(field)
      field.get_value.length
    end

    def eval_length(buf,length)
	    length = 0 if length.nil?
      if(length != 0)
	      if buf.length < length
	        raise BufferUnderflow, "Not enough data for parsing #{@id} (#{length}/#{buf.length})"
	      end
        return length
      else
        return buf.length
      end
    end
    
    def add_sub_codec(id_field,codec)
	    if codec.nil?
	      raise InitializeException, "Invalid codec reference in subcodec #{id_field} for codec #{@id}"
	    end
      if @subCodecs.kind_of? Hash
        @subCodecs[id_field] = codec 
      end
    end 
	
	  def get_sub_codecs
	    return @subCodecs
	  end
  end
end
