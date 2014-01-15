module Codec
  class Bitmap < Base
    NB_BITS_BY_BYTE = 8
    def initialize(length)
      @length=length
      @num_extended_bitmaps=[]
      @subCodecs = {}
    end
    
    def bitmap_length
      @length * NB_BITS_BY_BYTE
    end
    
    def add_extended_bitmap(num_extention)
      @num_extended_bitmaps << num_extention.to_i
    end
    
    def decode_bitmap(buffer,first_field_num)
      fields_ids = []
      bitmap = buffer.slice!(0...@length).unpack("B*").first
      field_num = first_field_num
      until(bitmap.empty?)
        fields_ids << field_num if bitmap.slice!(0) == "1"
        field_num += 1
      end
      return fields_ids
    end
    
    def encode_bitmap(buf,fields_list,bitmap_index)
      offset_id = bitmap_index * bitmap_length + 1
      bitmap = ""
      (offset_id...(offset_id + bitmap_length)).each do |i|
        if fields_list.include?(i)
          bitmap << "1"
        else
          bitmap << "0"
        end
      end
      Logger.debug { "Encoding bitmap #{bitmap_index} 
        form #{offset_id} to #{offset_id + bitmap_length - 1} 
        with #{fields_list.collect{|id| id.to_s}.join(',')}
        result #{bitmap}" }
      buf << [bitmap].pack("B*")
    end
    
    def encode(buf, field)
      Logger.debug { "Start bitmap encoding\n" }
      initial_length = buf.length
      fields = field.get_value 
      encoded_fields = []
      fields_list = fields.collect{|sf| sf.get_id.to_i}
      fields_list.sort!
      nb_additionnal_bitmaps = (fields_list.last - 1) / bitmap_length
      @num_extended_bitmaps[0...nb_additionnal_bitmaps].each{ |bitmap_field_id|
        Logger.debug{"adding bitmap = #{bitmap_field_id}\n"}
        fields_list << bitmap_field_id
        fields << Field.new(bitmap_field_id)
      }
      fields.sort!{|a,b| a.get_id.to_i <=> b.get_id.to_i}
      # Encode first bitmap
      bitmap_itt = 0
      encode_bitmap(buf,fields_list,bitmap_itt)
      fields.each do |sf|
        codec = @subCodecs[sf.get_id]
        if @num_extended_bitmaps.include?(sf.get_id)
          bitmap_itt += 1
          encode_bitmap(buf, fields_list, bitmap_itt)
        elsif codec.nil?
          raise EncodingException, "unknown codec for subfield #{sf.get_id}"
        elsif encoded_fields.include?(sf.get_id.to_i)
          raise EncodingException, "Multiple subfield #{sf.get_id} is invalid for Codec::Bitmap"
        else
          codec.encode(buf,sf)
        end
        encoded_fields << sf.get_id.to_i
      end
      return buf.length - initial_length      
    end

    def decode(buf,msg, length=nil)
      buf = buf.slice!(0...length) if length && length > 0
      field_num = 1
      # 1. read bitmap
      fields_list = decode_bitmap(buf,field_num)
      field_num += bitmap_length
      # 2. decode each field present
      while fields_list.length > 0
        # get next field number in bitmap
        field_id = fields_list.slice!(0)
        field_tag = field_id.to_s
        if @num_extended_bitmaps.include?(field_id)
          nextFields = decode_bitmap(buf,field_num)
          fields_list = fields_list + nextFields
        elsif @subCodecs[field_tag].respond_to?(:decode)
          Logger.debug "Parsing bitmap field #{field_tag}"
          f = Field.new(field_tag)
          @subCodecs[field_tag].decode(buf,f)
          msg.add_sub_field(f)
        else
  	      f = Field.new("ERR") 
  	      f.set_value(buf.unpack("H*").first)
  	      msg.add_sub_field(f)
          raise ParsingException.new "#{msg}\nError unknown field #{field_tag} : "
        end
      end
    end
  end
end
