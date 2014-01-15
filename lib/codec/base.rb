module Codec
  class Base
    
    def decode(buf,field)
      raise "Abstract Codec"
    end    

    def encode(buf,field)
      raise "Abstract Codec"
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
