module Codec
  class Tlv < Prefixedlength
    def initialize(length,header,content)
      super(length,content)
      @tag_codec = header
      @subCodecs = {}
    end

    def check_length(buf,length)
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
    
    def encode(buf, field)
      out = ""
      fields = field.get_value
      fields.each do |sf|
        @tag_codec.encode(out, Field.new('*',sf.get_id))
        if @subCodecs[sf.get_id]
          content = ""
          len = @subCodecs[sf.get_id].encode(content, sf)
          @length_codec.encode(out, Field.new('*',len))
          out << content
        else
          super(out, sf)
        end
      end
      buf << out
      return out.length
    end
    
    def decode(buffer, msg, length = nil)
      unless length.nil?
        l = check_length(buffer,length)
        buffer = buffer.slice!(0...l)
      end
      
      tag = Field.new
      begin
        until buffer.empty?
          begin
            @tag_codec.decode(buffer,tag)
          rescue
            raise ParsingException, "Tlv Codec still remaining data but failed to decode tag when decoding field #{msg.get_id}"
          end
          Logger.debug { "Decoding tag #{tag.get_value.to_s}"}
          sf = Field.new(tag.get_value.to_s)
          subcodec = @subCodecs[tag.get_value.to_s]
          if subcodec.nil?
            Logger.debug { "using default codec for tag #{tag.get_value.to_s}"}
            super(buffer,sf)
          else
            Logger.debug { "using predefined codec for tag #{tag.get_value.to_s}"}
            len_field = Field.new("len")
            @length_codec.decode(buffer,len_field)
            subcodec.decode(buffer,sf,len_field.get_value.to_i)
          end
          Logger.debug { "Add field #{sf} to tlv"}
          msg.add_sub_field(sf)
        end
      rescue BufferUnderflow => e
        raise ParsingException, "Tlv Codec failed to decode field #{msg.get_id}"
        val = Field.new
        val.set_value("Buffer underflow when parsing tlv #{msg.get_id} [#{buffer.unpack("H*").first}]")
        buffer.clear
      end
      unless buffer.empty? || length.nil?
        Logger.warn("Remain data in a tlv buffer :[#{buffer.unpack("H*").first}]") 
      end
    end
  end
  
  class Bertlv < Base
  
    def initialize
      @length = 0
    end

    def decode(buf,msg,length=nil)
      length ||= buf.length
      buffer = buf.slice!(0...length)
      until buffer.empty?
        sf = Field.new(tag_decode(buffer))
        val = value_decode(buffer, length_decode(buffer))
        sf.set_value(val)
    	  msg.add_sub_field(sf)
      end
    end
    
    def encode(buf, field)
      out = ""
      subfields = field.get_value
      unless subfields.kind_of?(Array)
        raise EncodingException, "Invalid field #{field.to_yaml} for BER Tlv encoding"
      end
      
      while subfields.size > 0
        subfield = subfields.shift
        out << tag_encode(subfield.get_id)
        # TODO : Handle value that is not String
        value = value_encode(subfield.get_value)
        out << length_encode(value.length)
        out << value
      end
      buf << out
      return out.length
    end
    
    private    
    
    def tag_decode(buf)
      # removing trailling bytes
      b = 0
      while (b == 0 || b == 255)
        b = buf.slice!(0).bytes.first
      end 
      tag = b.chr
      if (b & 0x1F == 0x1F) 
        begin 
          nb = buf.slice!(0).bytes.first
    	    tag << nb.chr
    	  end while nb & 0x80 == 0x80
      end
      return tag.unpack("H*").first.upcase
    end

    def tag_encode(tag)
      buf = [tag].pack("H*")
      pack_tag = buf.dup
      check_tag = tag_decode(buf)
      unless tag == check_tag && buf.empty?
        raise EncodingException, "Invalid BER tag [#{tag}]"
      end
      return pack_tag
    end
    
    def length_decode(buf)
     b = buf.slice!(0).bytes.first
     if b & 0x80 == 0x80
       # Compute lenght of encoding length 
       # Sample if first byte is 83 then lenth is encode 
       # on 3 bytes
       loencl = b & 0x7F 
       lb = buf.slice!(0...loencl)
       length = 0
       lb.bytes.each do |len_byte|
         length *= 256
    	   length += len_byte
       end
       return length
     else
       return b
     end
    end

    def length_encode(length)
      out = Numbin.numbin(length,0)
      if out.length > 127
       raise EncodingException,"Invalid length for BER Tlv #{length}"
      elsif out.length > 1
        out.prepend((128 + out.length).chr)
      end
      return out
    end
    
    def value_decode(buf, length)
      if length > buf.length
        raise BufferUnderflow.new "Not enough data for parsing BER TLV 
           #{@id} length value #{length} remaining only #{buf.length}"
      end
      value = buf.slice!(0...length)
      return value.unpack("H*").first.upcase
    end
  
    def value_encode(unpack_buffer)
      [unpack_buffer].pack("H*")
    end
  end
end
