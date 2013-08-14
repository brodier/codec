module Codec
  class Tlv < Prefixedlength
    def initialize(id,length,header,content)
      super(id,length,content)
      @tag_codec = header
      @subCodecs = {}
    end
    
    def decode_with_length(buf,length)
      l = eval_length(buf,length)
      f,r = decode(buf[0,l])
      Logger.warn("Remain data in a tlv buffer :[#{r.unpack("H*").first}]") if r.length > 0
      return f,buf[l,buf.length]
    end
    
    def encode(field)
      out = ""
      fields = field.get_value
      fields.each do |sf|
        out += @tag_codec.encode(Field.new('*',sf.get_id))
        if @subCodecs[sf.get_id]
          content = @subCodecs[sf.get_id].encode(sf)
          length_buffer = @length_codec.encode(Field.new('*',content.length))
          out += length_buffer + content
        else
          out += super(sf)
        end
      end
      return out
    end
  
    def decode(buffer)
      msg = Field.new(@id)
      while(buffer.length > 0)
        begin
          tag,buffer = @tag_codec.decode(buffer)
        rescue 
          val = Field.new("ERR")
          val.set_value("Error on parsing tag for TLV with following data [#{buffer.unpack("H*").first}]")
          msg.add_sub_field(val)
          return msg
        end
        begin
          if @subCodecs[tag.get_value.to_s].nil?
            val,buffer = super(buffer)
          else
            l,buf = @length_codec.decode(buffer)
            val,buffer = @subCodecs[tag.get_value.to_s].decode_with_length(buf,l.get_value.to_i)
          end
        rescue BufferUnderflow => e
          val = Field.new
          val.set_value("Buffer underflow when parsing this tag : #{e.message} [#{buffer.unpack("H*").first}]")
          buffer = ""
        rescue 
          val = Field.new
          val.set_value("Parsing error [#{buffer.unpack("H*").first}]")
          buffer = ""
        end
        
        val.set_id(tag.get_value.to_s)
        msg.add_sub_field(val)
      end
      return msg,buffer
    end
  end
  
  class Bertlv < Base
    def initialize(id)
      @id = id
      @length = 0
    end
    
    def tag_decode(buffer)
      buf = buffer.dup
      # removing trailling bytes
      begin ; b = buf.slice!(0).getbyte(0) ; end while (b == 0 || b == 255)
      tag = b.chr
      if (b & 0x1F == 0x1F) 
        begin 
          nb = buf.slice!(0).getbyte(0)
    	    tag += nb.chr
    	  end while nb & 0x80 == 0x80
      end
      return tag.unpack("H*").first.upcase, buf
    end

    def tag_encode(tag)
      buf = [tag].pack("H*")
      check_tag, remain = tag_decode(buf)
      if tag != check_tag || remain != ""
        raise EncodingException, "Invalid BER tag [#{tag}]"
      end
      return buf
    end
    
    def length_decode(buffer)
     buf = buffer.dup
     b = buf.slice!(0).getbyte(0)
     if b & 0x80 == 0x80
       # Compute lenght of encoding length sample if first byte is 83 then lenth is encode 
       # on 3 bytes
       loencl = b & 0x7F 
       lb = buf[0,loencl]
       buf = buf[loencl,buf.length]
       length = 0
       while(lb.length > 0)
         length *= 256
    	   length += lb.slice!(0).getbyte(0)
       end
       return length,buf
     else
       return b,buf
     end
    end

    def length_encode(length)
      out = Numbin.numbin(length,0)
      if out.length > 127
       raise EncodingException,"Invalid length for BER Tlv #{length}"
      elsif out.length > 1
        out = (128 + out.length).chr + out
      end
      return out
    end
    
    def value_decode(buf,length)
      if length > buf.length
        raise ErrorBufferUnderflow,"Not enough data for parsing BER TLV 
           #{@id} length value #{length} remaining only #{buf.length}"
      end
      value = buf[0,length]
      buf = buf[length,buf.length]
      return value.unpack("H*").first.upcase,buf
    end
  
    def value_encode(unpack_buffer)
      [unpack_buffer].pack("H*")
    end
    
    def build_field(buf,length)
      msg = Field.new(@id)
      buffer = buf[0,length]
      while buffer.length > 0
        tag,buffer = tag_decode(buffer)
        f = Field.new(tag)
        value_length,buffer = length_decode(buffer)
        value, buffer = value_decode(buffer,value_length)
    	  f.set_value(value)
    	  msg.add_sub_field(f)
      end
      return msg
    end
  
    def decode(buffer)
      return build_field(buffer,buffer.length),""
    end
    
    def encode(field)
      out = ""
      subfields = field.get_value
      unless subfields.kind_of?(Array)
        raise EncodingException, "Invalid field #{field.to_yaml} for BER Tlv encoding"
      end
      
      while subfields.size > 0
        subfield = subfields.shift
        out += tag_encode(subfield.get_id)
        # TODO : Handle value that is not String
        value = value_encode(subfield.get_value)
        out += length_encode(value.length)
        out += value
      end
      return out
    end
  end
end
