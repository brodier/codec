module Codec
  class Packed < Base
    def get_pck_length(length)
      ((length + 1) / 2)
    end
    
    def get_length(field)
      if @length > 0
        return @length 
      else
        return field.get_value.to_s.length
      end
    end	
    
    def encode_with_length(field)
      return get_length(field),encode(field)
    end
    
    def decode_with_length(buf,length)
      l = eval_length(buf,get_pck_length(length))
      return build_field(buf,l),buf[l,buf.length]
    end
    
    def decode(buf)
      return decode_with_length(buf,@length)
    end
  end

  class Numpck < Packed
    def decode_with_length(buf,length)
      l = eval_length(buf,get_pck_length(length))
      f = Field.new(@id)
      val = buf[0,l].unpack("H*").first
      if @length.odd?
        val = val[1,val.length]
      else
        val = val[1,val.length] if length.odd?
      end
      f.set_value(val.to_i)
      return f,buf[l,buf.length]
    end
    
    def encode(field)
      out = field.get_value.to_s
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      l = out.length
      out.prepend("0") if out.length.odd?
      out = [out].pack("H*")
      return out
    end
  end
  
  class Strpck < Packed
    def decode_with_length(buf,length)
      l = eval_length(buf,get_pck_length(length))
      f = Field.new(@id)
      val = buf[0,l].unpack("H*").first
      if @length.odd?
        val.chop! 
      else
        val.chop! if length.odd?
      end
      f.set_value(val)
      return f,buf[l,buf.length]
    end
    
    def encode(field)
      out = field.get_value.to_s
      if @length > 0
        out = out.ljust(@length,"F")
        raise TooLongDataException if out.length > @length
      end
      l = out.length
      out += "F" if out.length.odd?
      out = [out].pack("H*")
      return out
    end
  end
  
  class Nstpck < Packed
    def decode_with_length(buf,length)
      l = eval_length(buf,get_pck_length(length))
      f = Field.new(@id)
      val = buf[0,l].unpack("H*").first
      if @length.odd?
        val = val[1,val.length]
      else
        val = val[1,val.length] if length.odd?
      end
      f.set_value(val)
      return f,buf[l,buf.length]
    end
    
    def encode(field)
      out = field.get_value
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      l = out.length
      out.prepend("0") if out.length.odd?
      out = [out].pack("H*")
      return out
    end
  end
  
end