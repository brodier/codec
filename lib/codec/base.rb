module Codec
  class Base
    attr_reader :id
    def initialize(id,length)
        @length = length.to_i
        @id = id
    end

    def build_field
      f = Field.new(@id)
      f.set_value(@data)
      return f
    end
    
    def decode_with_length(buf,length)
      init_data(buf,length)
      return build_field,@remain
    end
    
    def decode(buf)
      init_data(buf,@length)
      return build_field,@remain
    end    
    
    def init_data(buf,length)
	    length = 0 if length.nil?
      if(length != 0)
	      if buf.length < length
	        raise BufferUnderflow, "Not enough data for parsing #{@id} (#{length}/#{buf.length})"
	      end
        @data = buf[0,length]
        @remain = buf[length,buf.length]
      else
        @data = buf
        @remain = ""
      end
    end
    
    def add_subparser(id_field,parser)
	    if parser.nil?
	      raise InitializeException, "Invalid codec reference in subparser #{id_field} for codec #{@id}"
	    end
      if @subParsers.kind_of? Hash
        @subParsers[id_field] = parser 
      end
    end 
	
	  def get_sub_parsers
	    return @subParsers
	  end
  end
end
