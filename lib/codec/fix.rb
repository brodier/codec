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
  end


  
  class Numstr < Base
    def build_field
      f = Field.new(@id)
	  # Force conversion of ebcdic number to ascii number
	  if IsEbcdic(@data)
	    @data = Ebcdic2Ascii(@data)
	  end
	  
      f.set_value(@data.to_i)
      return f
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