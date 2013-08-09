module Codec
  class Numbin < Base
    def build_field
      f = Field.new(@id)
      res = 0
      @data.unpack("C*").each{ |ubyte|
        res *= 256
        res += ubyte
      }
      f.set_value(res)
      return f
    end
    
    def encode(field)
      val = field.get_value.to_i
      out = ""
      while val > 0
        out << (val % 256).chr
        val /= 256
      end
      
      # handle length if defined
      if @length > 0
        while out.length < @length
          out << 0.chr
        end
        out = out[0,@length]
      end
      
      return out.reverse
    end
  
  end

  class Numasc < Base
    def build_field
      f = Field.new(@id)
      f.set_value(@data.to_i)
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
    def build_field
      f = Field.new(@id)
	  if IsEbcdic(@data)
	    @data = Ebcdic2Ascii(@data)
	  end
      f.set_value(@data)
      return f
    end
  end

  class Binary < Base
    def build_field
      f = Field.new(@id)
      f.set_value(@data.unpack("H*").first.upcase)
      return f
    end
  end
end