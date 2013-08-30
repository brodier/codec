module Codec
  
  class Numbin < Base
    def build_field(buf,length)
      f = Field.new(@id)
      res = 0
      buf[0,length].unpack("C*").each{ |ubyte|
        res *= 256
        res += ubyte
      }
      f.set_value(res)
      return f
    end
    
    def encode(field)
      val = field.get_value.to_i
      out = Numbin.numbin(val,@length)
      return out
    end
    
    def self.numbin(number,maxlength)
      out = ""
      while number > 0
        out << (number % 256).chr
        number /= 256
      end
      
      # handle length if defined
      if maxlength > 0
        while out.length < maxlength
          out << 0.chr
        end
        out = out[0,maxlength]
      end
      out = 0.chr if out == ""
      return out.reverse
    end
  end

  class Numstr < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(buf[0,length].to_i)
      return f
    end
    
    def encode(field)
      out = field.get_value.to_s
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      return out
    end
  end

  class Numasc < Numstr
    # This class is a copy of Numstr class because UTF8 and ASCII 
    # have the same encoding for digits number
  end
  
  class Numebc < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(EightBitsEncoding::EBCDIC_2_UTF8(buf[0,length]).to_i)
      return f
    end
    
    def encode(field)
      out = field.get_value.to_s
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      return EightBitsEncoding::UTF8_2_EBCDIC(out)
    end
    
  end
  
  class Ebcdic < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(EightBitsEncoding::EBCDIC_2_UTF8(buf[0,length]))
      return f
    end
    
    def encode(f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      return EightBitsEncoding::UTF8_2_EBCDIC(out)
    end  
  end
  
  class Ascii < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(EightBitsEncoding::ASCII_2_UTF8(buf[0,length]))
      return f
    end
    
    def encode(f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      return EightBitsEncoding::UTF8_2_ASCII(out)
    end    
  end
  
  class String < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(buf[0,length])
      return f
    end
    
    def encode(f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      return out
    end    
  end

  class Binary < Base
    def build_field(buf,length)
      f = Field.new(@id)
      f.set_value(buf[0,length].unpack("H*").first.upcase)
      return f
    end
    
    def encode(f)
      out = [f.get_value].pack("H*")
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length,0.chr)
      end
      return out
    end 
  end
end
