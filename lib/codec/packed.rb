module Codec
  class Packed < Base
    def initialize(length, isNumeric = true, isLeftPadded=false, isFPadded = false)
      @length = length
      @isNum = isNumeric
      @fPad = isFPadded
      @lPad = isLeftPadded
    end
    
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
    
    def decode_with_length(buf, f, length)
      l = eval_length(buf,get_pck_length(length))
      val = buf.slice!(0...l).unpack("H*").first
      # remove padding if odd length
      ( @lPad ? val.chop! : val.slice!(0) ) if @length.odd? || length.odd?
      val = val.to_i if @isNum
      f.set_value(val)
    end
    
    def decode(buf,field)
      decode_with_length(buf, field, @length)
    end

    def encode(buf, field)
      out = field.get_value.to_s
      Logger.debug{ "Encode packed #{out} on #{@length} [#{@isNum}|#{@fPad}|#{@lPad}]" }
      padding = (@fPad ? "F" : "0")
      if @length > 0
        out = (@lPad ? out.ljust(@length,padding) : out.rjust(@length,padding))
        raise TooLongDataException if out.length > @length
      end
      l = out.length
      # handle padding if odd length
      (@lPad ? out << padding : out.prepend(padding) )if out.length.odd?
      Logger.debug{ "before packing : #{out}" }
      out = [out].pack("H*")
      buf << out
      return l
    end
  end
  
end