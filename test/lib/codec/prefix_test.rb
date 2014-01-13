require_relative '../../test_helper'

describe Codec::Prefixedlength do
  before do
    @length = Codec::Numasc.new(3)
    @content = Codec::String.new(0)
    @field = Codec::Field.new
    @field.set_value("0012AB")
    @f = Codec::Field.new
    @buffer = "0060012AB"
  end

  subject { Codec::Prefixedlength.new(@length,@content) }
  
  it "must generate a field with computed value" do
    subject.decode(@buffer,@f)
    @f.get_value.must_equal("0012AB")
  end
  
  it "remaining buffer must be empty" do
    subject.decode(@buffer,@f)
    @buffer.must_be_empty
  end

  it "must encode value prefixed with length" do
    buffer = ""
    subject.encode(buffer, @field)
    buffer.must_equal("0060012AB")
  end
end

describe Codec::Headerlength do
  before do
    tag = Codec::Binary.new(1)
    length = Codec::Numbin.new(1)
    value = Codec::Numbin.new(0)
    tlv = Codec::Tlv.new(length,tag,value)
    @header = Codec::BaseComposed.new
    @header.add_sub_codec('H_TAG',tag)
    @header.add_sub_codec('H_TLV',Codec::Prefixedlength.new(length,tlv))
    @content = Codec::String.new(0)
    len = 6
    field_head = ['HEADER', [['H_TAG','AA'],['H_TLV',[['01',25],['02',len]]]]]
    field_content = ['CONTENT','STRING']
    field_array = [ field_head, field_content]
    @field_with_length = Codec::Field.from_array('Test_Headerlength',field_array)
    len = 0
    field_head = ['HEADER', [['H_TAG','AA'],['H_TLV',[['01',25],['02',len]]]]]
    field_array = [ field_head, field_content]
    @field_without_length = Codec::Field.from_array('Test_Headerlength',field_array)
    field_array = [field_content]
    @field_without_head = Codec::Field.from_array('Test_Headerlength',field_array)
    @buffer = ["AA06010119020106","STRING"].pack("H*A*")
    @working_field = Codec::Field.new('Test_Headerlength')
  end

  subject { Codec::Headerlength.new(@header, 'HEADER',@content,'CONTENT','.H_TLV.02') }
  
  it "must decode a field with computed value" do
    subject.decode(@buffer,@working_field)
    @working_field.must_equal(@field_with_length)
  end
  
  it "must also return remaining data" do
    buffer = @buffer + "REMAIN"
    subject.decode(buffer, @working_field)
    buffer.must_equal("REMAIN")
  end

  it "must encode buffer with composed field [header,content]" do
    buffer = ""
    subject.encode(buffer, @field_without_length)
    buffer.must_equal(@buffer)
  end
  
  it "must raise EncodingException if missing header field" do
    buf =""
    proc { subject.encode(buf, @field_without_head)}.must_raise(Codec::EncodingException)
  end
  
end

describe Codec::Tagged do
  before do
    @field1 = Codec::Field.new('01',12)
    @field2 = Codec::Field.new('02','ABC')
    @buffer1 = "01012"
    @buffer2 = "02ABC"
    @working_field = Codec::Field.new
  end

  subject { c = Codec::Tagged.new(Codec::String.new(2)) 
            c.add_sub_codec('01',Codec::Numasc.new(3))
            c.add_sub_codec('02',Codec::String.new(3))
            c
          }
  
  it "must generate a field with computed value" do
    subject.decode(@buffer1,@working_field)
    @working_field.must_equal(@field1)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@buffer2,@working_field)
    @working_field.must_equal(@field2)
  end  

  it "must encode value prefixed with length" do
    buffer = ""
    subject.encode(buffer, @field1)
    buffer.must_equal(@buffer1)
  end

  it "must encode value prefixed with length" do
    buffer =""
    subject.encode(buffer, @field2)
    buffer.must_equal(@buffer2)
  end
end
