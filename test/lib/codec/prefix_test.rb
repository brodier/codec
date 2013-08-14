require_relative '../../test_helper'

describe Codec::Prefixedlength do
  before do
    @length = Codec::Numasc.new('length',3)
    @content = Codec::String.new('content',0)
    @field = Codec::Field.new
    @field.set_value("0012AB")
    @buffer = "0060012AB"
  end

  subject { Codec::Prefixedlength.new('Test_lvar',@length,@content) }
  
  it "must be a Prefixedlength codec" do
    subject.must_be_instance_of(Codec::Prefixedlength)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@buffer).first.get_value.must_equal("0012AB")
  end
  
  it "must also return remaining data" do
    subject.decode(@buffer).last.must_equal("")
  end

  it "must encode value prefixed with length" do
    subject.encode(@field).must_equal("0060012AB")
  end
end

describe Codec::Headerlength do
  before do
    tag = Codec::Binary.new('T',1)
    length = Codec::Numbin.new('L',1)
    value = Codec::Numbin.new('V',0)
    tlv = Codec::Tlv.new('TAG',length,tag,value)
    @header = Codec::BaseComposed.new('HEADER')
    @header.add_sub_codec('H_TAG',tag)
    @header.add_sub_codec('H_TLV',Codec::Prefixedlength.new('*',length,tlv))
    @content = Codec::String.new('CONTENT',0)
    len = 6
    field_array = [['HEADER', [['H_TAG','AA'],['H_TLV',[['01',25],['02',len]]]]],
      ['CONTENT','STRING']]
    @field_with_length = Codec::Field.from_array('Test_Headerlength',field_array)
    len = 0
    field_array = [['HEADER', [['H_TAG','AA'],['H_TLV',[['01',25],['02',len]]]]],
      ['CONTENT','STRING']]
    @field_without_length = Codec::Field.from_array('Test_Headerlength',field_array)
    @buffer = ["AA06010119020106","STRING"].pack("H*A*")
  end

  subject { Codec::Headerlength.new('Test_Headerlength',@header,@content,'.H_TLV.02') }
  
  it "must be a Headerlength codec" do
    subject.must_be_instance_of(Codec::Headerlength)
  end
  
  it "must decode a field with computed value" do
    subject.decode(@buffer).first.must_equal(@field_with_length)
  end
  
  it "must also return remaining data" do
    subject.decode(@buffer + "REMAIN").last.must_equal("REMAIN")
  end

  it "must encode buffer with composed field [header,content]" do
    subject.encode(@field_without_length).must_equal(@buffer)
  end
end
