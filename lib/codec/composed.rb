module Codec
  class SimpleComposed < Base
    def initialize(id)
      @id = id
      @subCodecs = []
    end
  
    def build_field(buf,length)
      msg = Field.new(@id)
      working_buf = buf[0,length]
      @subCodecs.each{|id,codec|
        Logger.debug "Parsing struct field #{@id} : #{id}"
  	    if working_buf.length == 0
  	      f = Field.new(id)
  	      f.set_value("")
  	    else 
          f,working_buf = codec.decode(working_buf)
  	    end
        f.set_id(id)
        msg.add_sub_field(f)
      }
    
      if working_buf.length > 0
        if @length_unknown 
  	      @remain = working_buf 
  	    else
          f = Field.new("PADDING")
  	      f.set_value(working_buf.unpack("H*").first)
  	      msg.add_sub_field(f)
  	    end
      end
      return msg
    end
  
    def add_sub_codec(id_field,codec)
      if codec.nil?
        raise InitializeException, "Invalid codec reference in subcodec #{id_field} for codec #{@id}"
      end
      @subCodecs << [id_field, codec]
    end 
  end
  
  class CompleteComposed
    def build_field(buf,length)
      f,r = super(buf,length)
      # Check if all struct's fields have been parsed
      # else raise an error
      if f.get_value.size < @subCodecs.size 
        raise BufferUnderflow, "Not enough data for parsing Struct #{@id}" 
      end
      return f,r
    end
  end
  
  class Bitmap < Base
    NB_BITS_BY_BYTE = 8
    def initialize(id,length)
      super(id,length)
      @num_extended_bitmaps=[]
      @subCodecs = {}
    end
    
    def add_extended_bitmap(num_extention)
      @num_extended_bitmaps << num_extention.to_i
    end
    
    def decodeBitmap(buffer,first_field_num)
      fieldsList = []
      
      bitmapBuffer = buffer[0,@length].unpack("B*").first
      buf = buffer[@length,buffer.length]
      field_num = first_field_num
      while(bitmapBuffer.length > 0)
        fieldsList << field_num if bitmapBuffer.start_with?('1')
        bitmapBuffer.slice!(0)
        field_num += 1
      end
      return fieldsList, buf
    end
    
    def decode(buffer)
      msg = Field.new(@id)
      field_num = 1
      # 1. read bitmap
      fields_list,buf = decodeBitmap(buffer,field_num)
      field_num += @length * NB_BITS_BY_BYTE
      # 2. decode each field present
      while fields_list.length > 0
        # get next field number in bitmap
        field_id = fields_list.slice!(0)
        field_tag = field_id.to_s
        if @num_extended_bitmaps.include?(field_id)
          nextFields,buf = decodeBitmap(buf,field_num)
          fields_list = fields_list + nextFields
        elsif @subCodecs[field_tag].respond_to?(:decode)
          Logger.debug "Parsing bitmap field #{field_tag}"
          f,buf = @subCodecs[field_tag].decode(buf)
          f.set_id(field_tag)
          msg.add_sub_field(f)
        else
  	      f = Field.new("ERR") 
  	      f.set_value(buf.unpack("H*").first)
  	      msg.add_sub_field(f)
          raise ParsingException,msg.to_yaml + "\nError unknown field #{field_tag} : "
        end
      end
      return msg,buf
    end
  end
  
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