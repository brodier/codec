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
    def initialize(att)
      @id = att['id']
    end
  
    def read_length
     b = @data.slice!(0).getbyte(0)
     if b & 0x80 == 0x80
       ll = b & 0x7F 
       lb = @data[0,ll]
       @data = @data[ll,@data.length]
       length = 0
       while(lb.length > 0)
         length *= 256
    	   length += lb.slice!(0).getbyte(0)
       end
       return length
     else
       return b
     end
    end
  
    def read_tag
      b = 0
      while b == 0 || b == 255
        b = @data.slice!(0).getbyte(0)
      end
    
      tag = b.chr
      
      if b & 0x1F == 0x1F
        nb = 0x80
        while nb & 0x80 == 0x80
          nb = @data.slice!(0).getbyte(0)
    	    tag += nb.chr
    	  end
      end
      return tag.unpack("H*").first.upcase
    end
    
    def read_value(length)
      raise ErrorBufferUnderflow,"Not enough data for parsing BER TLV #{@id} length value #{length} remaining only #{@data.length}" if length > @data.length
      value = @data[0,length]
      @data = @data[length,@data.length]
      return value.unpack("H*").first.upcase
    end
  
    def build_field(buf,length)
      msg = Field.new(@id)
      @data = buf[0,length]
      while @data.length > 0
        f = Field.new(read_tag)
    	  f.set_value(read_value(read_length))
    	  msg.add_sub_field(f)
      end
      return msg
    end
  
    def decode(buffer)
      return build_field(buffer,buffer.length),""
    end
  end
end