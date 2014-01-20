module Codec
  class BaseComposed < Base
    def initialize(isComplete = false)
      @is_complete = isComplete
      @subCodecs = {}
    end
    
    def decode(buf,msg, length = nil)
      unless length.nil?
        Logger.debug {"build composed for [#{buf.unpack("H*").first}] on #{length} bytes for #{msg.get_id} field"}
        buf = buf.slice!(0...length)
      end
      
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
      unless buf.empty? || length.nil?
        f = Field.new("PADDING")
        f.set_value(buf.unpack("H*").first)
        msg.add_sub_field(f)
      end
      
      # Check if all struct's fields have been parsed
      if @is_complete && msg.get_value.size < @subCodecs.size 
        raise BufferUnderflow, "Not enough data for parsing Struct #{msg.get_id}" 
      end      
    end
    
    def encode(buf, field)

      if @is_complete && @subCodecs.size != field.get_value.size
        raise EncodingException, "Not enough subfields to encode #{field.get_id}"
      end
      
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
  end
end
