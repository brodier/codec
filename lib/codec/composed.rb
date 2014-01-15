module Codec
  class BaseComposed < Base
    def initialize
      @subCodecs = {}
    end
    
    def decode(buf,msg)
      @subCodecs.each{|id,codec|
        Logger.debug "Parsing struct field #{msg.get_id} - #{id} with [#{buf.unpack("H*").first}]"
  	    if buf.empty?
          Logger.debug "Not enough data to decode #{msg.get_id} : #{id}"
        else
          f = Field.new(id)
          codec.decode(buf,f)
          msg.add_sub_field(f)
	      end
      }    
    end
    
    def encode(buf, field)
      return if field.empty?
      initial_length = buf.length
      subfields = field.get_value
      composed_encoder = subfields.zip(@subCodecs).collect {|sf,sc|
        if sf.get_id != sc.first
          raise EncodingException, "subfield #{sf.first} not correspond to subcodec #{sc.first}"
        end
        [sc.last,sf]
      } 
      composed_encoder.each do |subcodec,subfield|
        subcodec.encode(buf,subfield)
      end
      return buf.length - initial_length
    end
    
    def decode_with_length(buf,msg,length)
      Logger.debug {"build composed for [#{buf.unpack("H*").first}] on #{length} bytes for #{msg.get_id} field"}
      composed_buf = buf.slice!(0...length)
      decode(composed_buf, msg)
      unless composed_buf.empty?
        f = Field.new("PADDING")
        f.set_value(composed_buf.unpack("H*").first)
        msg.add_sub_field(f)
      end
    end

  end
  
  class CompleteComposed < BaseComposed
    def decode(buf,field)
      super(buf,field)
      # Check if all struct's fields have been parsed
      if field.get_value.size < @subCodecs.size 
        raise BufferUnderflow, "Not enough data for parsing Struct #{@id}" 
      end
    end
    
    def encode(buf, field)
      if @subCodecs.size != field.get_value.size
        raise EncodingException, "Not enough subfields to encode #{@id}"
      end
      super(buf, field)
    end
  end
end
