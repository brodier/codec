module Codec
  class Packed < Base
    def get_pck_length(length)
      ((length + 1) / 2)
    end
    
    def eval_pck_length(field)
      if @length > 0
        return @length 
      else
        return field.get_value.to_s.length
      end
    end	
    
    def decode_with_length(buf,length)
      init_data(buf,get_pck_length(length))
      return build_field,@remain
    end
    
    def decode(buf)
      return decode_with_length(buf,@length)
    end
  end

  class Numpck < Packed
    def build_field
      f = Field.new(@id)
      f.set_value(@data.unpack("H*").first.to_i)
      return f
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
    def build_field
      f = Field.new(@id)
      val = @data.unpack("H*").first
      val.chop! if @length.odd?
      f.set_value(val)
      return f
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

end