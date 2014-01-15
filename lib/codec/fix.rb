module Codec
  class Fix < Base
    
    def initialize(length=nil)
      @length = length || 0
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

    def decode_with_length(buf,field,length)
      l = check_length(buf,length)
      wbuf = buf.slice!(0...l)
      build_field(wbuf,field,l)    
    end
    
    def decode(buf,field)
      decode_with_length(buf,field,@length)
    end
    
    def build_field(w,f,l)
      raise "Abstract Codec : build field not defined for #{self.class.name}"
    end
  end
  class Numbin < Fix
    def build_field(buf,f,length)
      res = 0
      buf.slice!(0...length).unpack("C*").each{ |ubyte|
        res *= 256
        res += ubyte
      }
      f.set_value(res)
    end
    
    def encode(buf, field)
      val = field.get_value.to_i
      out = Numbin.numbin(val,@length)
      buf << out
      return out.length
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

  class Numstr < Fix
    def build_field(buf, f, length)
      f.set_value(buf.slice!(0...length).to_i)
    end
    
    def encode(buf,field)
      out = field.get_value.to_s
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      buf << out
      return out.length
    end
  end

  class Numasc < Numstr
    # This class is a copy of Numstr class because UTF8 and ASCII 
    # have the same encoding for digits number
  end
  
  class Numebc < Fix
    def build_field(buf,f,length)
      f.set_value(EightBitsEncoding::EBCDIC_2_UTF8(buf.slice!(0...length)).to_i)
    end
    
    def encode(buf, field)
      out = field.get_value.to_s
      if @length > 0
        out = out.rjust(@length,"0")
        raise TooLongDataException if out.length > @length
      end
      buf << EightBitsEncoding::UTF8_2_EBCDIC(out)
      return out.length      
    end
    
  end
  
  class Ebcdic < Fix
    def build_field(buf, f, length)
      f.set_value(EightBitsEncoding::EBCDIC_2_UTF8(buf.slice!(0...length)))
    end
    
    def encode(buf, f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      buf << EightBitsEncoding::UTF8_2_EBCDIC(out)
      return out.length      
    end  
  end
  
  class Ascii < Fix
    def build_field(buf, f, length)
      f.set_value(EightBitsEncoding::ASCII_2_UTF8(buf.slice!(0...length)))
    end
    
    def encode(buf, f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      buf << EightBitsEncoding::UTF8_2_ASCII(out)
      return out.length      
    end    
  end
  
  
  class String < Fix
    def build_field(buf, f, length)
      f.set_value(buf.slice!(0...length))
    end
    
    def encode(buf, f)
      out = f.get_value
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length," ")
      end
      buf << out
      return out.length
    end    
  end

  class Binary < Fix
    def build_field(buf, field, length)
      field.set_value(buf.slice!(0...length).unpack("H*").first.upcase)
    end
    
    def encode(buf, f)
      out = [f.get_value].pack("H*")
      if @length >  0
        raise TooLongDataException if out.length > @length
        out = out.ljust(@length,0.chr)
      end
      buf << out
      return out.length
    end 
  end

  # Class Auto Converting Ebcdic to ASCII for number and string
    EBCDIC_2_ASCII = ["000102039C09867F978D8E0B0C0D0E0F101112139D8508871819928F1C1D1E1F"+
      "80818283840A171B88898A8B8C050607909116939495960498999A9B14159E1A"+
      "20A0A1A2A3A4A5A6A7A8D52E3C282B7C26A9AAABACADAEAFB0B121242A293B5E"+
      "2D2FB2B3B4B5B6B7B8B9E52C255F3E3FBABBBCBDBEBFC0C1C2603A2340273D22"+
      "C3616263646566676869C4C5C6C7C8C9CA6A6B6C6D6E6F707172CBCCCDCECFD0"+
      "D17E737475767778797AD2D3D45BD6D7D8D9DADBDCDDDEDFE0E1E2E3E45DE6E7"+
      "7B414243444546474849E8E9EAEBECED7D4A4B4C4D4E4F505152EEEFF0F1F2F3"+
      "5C9F535455565758595AF4F5F6F7F8F930313233343536373839FAFBFCFDFEFF"].pack("H*")
  
  class Numace < Numstr
    def build_field(buffer, f, length)
      data = ""
      buf = buffer.slice!(0...length)
      # if buf to decode is in EBCDIC then convert buf in ASCII
      if ( buf.unpack("C*").select{|c| c >= 128}.size > 0)
        buf.unpack("C*").each { |c| data << EBCDIC_2_ASCII[c] }
      else
        data = buf
      end
      f.set_value(data.to_i)
    end
  end

  class Strace < String
    def build_field(buffer, field, length)
      data = ""
      buf = buffer.slice!(0...length)
      # if buf to decode is in EBCDIC then convert buf in ASCII
      if ( buf.unpack("C*").select{|c| c >= 128}.size > 0)
        buf.unpack("C*").each { |c| data += EBCDIC_2_ASCII[c] }
      else
        data = buf
      end
      f.set_value(data)
    end
  end
end
