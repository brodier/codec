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
      return out.reverse
    end
  end

  class Numasc < Base
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