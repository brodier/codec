module Codec
  class Bitmap < Base
    NB_BITS_BY_BYTE = 8
    def initialize(id,length)
      super(id,length)
      @num_extended_bitmaps=[]
      @subCodecs = {}
    end
    
    def bitmap_length
      @length * NB_BITS_BY_BYTE
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
    
    def encode_bitmap(fields_list,bitmap_index)
      offset = bitmap_index * bitmap_length
      bitmap = ""
      ((offset + 1)..(offset + bitmap_length)).each do |i|
        if fields_list.include?(i)
          bitmap += "1"
        else
          bitmap += "0"
        end
      end
      return [bitmap].pack("B*")
    end
    
    def encode(field)
      fields = field.get_value 
      encoded_fields = []
      fields_list = fields.collect{|sf| sf.get_id.to_i}
      # Add field for bitmaps
      bitmap_fields = @num_extended_bitmaps[0,(fields_list.last - 1) / bitmap_length]
      fields_list +=  bitmap_fields
      fields += bitmap_fields.collect {|id| Field.new(id)}
      fields.sort!{|a,b| a.get_id.to_i <=> b.get_id.to_i}
      # Encode first bitmap
      out = encode_bitmap(fields_list,0)
      bitmap_index = 1
      fields.each do |sf|
        codec = @subCodecs[sf.get_id]
        if @num_extended_bitmaps.include?(sf.get_id)
          out += encode_bitmap(fields_list,bitmap_index)
          bitmap_index += 1
        elsif codec.nil?
          raise EncodingException, "unknown codec for subfield #{sf.get_id}"
        elsif encoded_fields.include?(sf.get_id.to_i)
          raise EncodingException, "Multiple subfield #{sf.get_id} is invalid for Codec::Bitmap"
        else
          out += codec.encode(sf)
        end
        encoded_fields << sf.get_id.to_i
      end
      return out
    end
    
    def decode(buffer)
      msg = Field.new(@id)
      field_num = 1
      # 1. read bitmap
      fields_list,buf = decodeBitmap(buffer,field_num)
      field_num += bitmap_length
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
          raise ParsingException.new "#{msg}\nError unknown field #{field_tag} : "
        end
      end
      return msg,buf
    end
  end
end
