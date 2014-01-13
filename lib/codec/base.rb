module Codec
  class Base
    def initialize(length)
        @length = length.to_i
    end

    def build_field(buf,field,length)
      field.set_value(buf.slice!(0...length))
    end
    
    def decode_with_length(buf,field,length)
      l = eval_length(buf,length)
      build_field(buf,field,l)
    end
    
    def decode(buf,field)
      l = eval_length(buf,@length)
      build_field(buf,field,l)
    end    

    def encode(buf,field)
      l=field.get_value.to_s.length
      buf << field.get_value.to_s
      return l
    end
    
    def get_length(field)
      field.get_value.length
    end

    def eval_length(buf,length)
	    raise "Length is nil" if length.nil?
      if(length != 0)
	      if buf.length < length
	        raise BufferUnderflow, "Not enough data for decoding (#{length}/#{buf.length})"
	      end
        return length
      else
        return buf.length
      end
    end
    
    def add_sub_codec(field_id,codec)
	    if codec.nil?
	      raise InitializeException, "Invalid codec reference in subcodec #{field_id} for codec #{@id}"
	    end
      @subCodecs ||= {}
      @subCodecs[field_id] = codec 
    end 
	
	  def get_sub_codecs
	    return @subCodecs
	  end
  end
end
