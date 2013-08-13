module Codec
  class BaseComposed < Base
    def initialize(id)
      @id = id
      @subCodecs = []
    end
    
    def decode(buf)
      return build_each_field(buf,buf.length)
    end
    
    def encode(field)
      subfields = field.get_value
      composed_encoder = subfields.zip(@subCodecs).collect {|sf,sc|
        if sf.first != sc.first
          raise EncodingException, "subfield #{sf.first} not correspond to subcodec #{sc.first}"
        end
        [sc.last,sf.last]
      } 
      out = ""
      composed_encoder.each do |subcodec,subfield|
        out += subcodec.encode(subfield)
      end
      return out
    end
    
    def build_each_field(buf,length)
      msg = Field.new(@id)
      working_buf = buf[0,length]
      @subCodecs.each{|id,codec|
        Logger.debug "Parsing struct field #{@id} : #{id}"
  	    if working_buf.length == 0
          Logger.debug "Not enough data to decode #{@id} : #{id}"
        else
          f,working_buf = codec.decode(working_buf)
          f.set_id(id)
          msg.add_sub_field(f)
	      end
      }
      return msg,working_buf
    end
    
    def build_field(buf,length)
      msg,working_buf = build_each_field(buf,length)
      
      if working_buf.length > 0
        if @length_unknown 
  	      @remain = working_buf 
  	    else
          f = Field.new("PADDING")
  	      f.set_value(working_buf.unpack("H*").first)
  	      msg.add_sub_field(f)
  	    end
      end
      return msg
    end
  
    def add_sub_codec(id_field,codec)
      if codec.nil?
        raise InitializeException, "Invalid codec reference in subcodec #{id_field} for codec #{@id}"
      end
      @subCodecs << [id_field, codec]
    end 
  end
  
  class CompleteComposed < BaseComposed
    def build_each_field(buf,length)
      f,r = super(buf,length)
      # Check if all struct's fields have been parsed
      if f.get_value.size < @subCodecs.size 
        raise BufferUnderflow, "Not enough data for parsing Struct #{@id}" 
      end
      return f,r
    end
    
    def encode(field)
      if @subCodecs.size != field.get_value.size
        raise EncodingException, "Not enough subfields to encode #{@id}"
      end
      super(field)
    end
  end
end