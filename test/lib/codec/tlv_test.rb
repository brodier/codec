require_relative '../../test_helper'

describe Codec::Tlv do
  subject { Codec::Tlv.new(Codec::Numbin.new(1), 
              Codec::Binary.new(1), 
              Codec::Binary.new(0))
          }
  
  before do
    @buffer = ["950580000000009C0100"].pack("H*")
    @field = Codec::Field.from_array('Tlv',[['95','8000000000'],['9C','00']])
    @wf = Codec::Field.new('Tlv')
  end
  
  it "must generate composed field from buffer" do
    subject.decode(@buffer,@wf)
    @wf.must_equal(@field)
  end

  it "must generate buffer from composed field" do
    buff = ""
    subject.encode(buff, @field)
    buff.must_equal(@buffer)
  end  
end

describe Codec::Tlv do
  subject { Codec::Tlv.new( Codec::Numbin.new(1), 
              Codec::Binary.new(1),
              Codec::Binary.new(0))
          }
  
  before do
    tvr_codec = Codec::BaseComposed.new()
    one_byte_codec = Codec::Binary.new(1)
    (1..5).each do |i|
      tvr_codec.add_sub_codec("BIT#{i}",one_byte_codec)
    end
    subject.add_sub_codec('95',tvr_codec)

    @buffer = ["950580000000009C0100"].pack("H*")
    @field = Codec::Field.from_array('Tlv',
      [['95',[['BIT1','80'],['BIT2','00'],['BIT3','00'],
       ['BIT4','00'],['BIT5','00']]],['9C','00']])
    @wf = Codec::Field.new('Tlv')
  end

  it "must generate composed field from buffer" do
    Codec::Logger.debug {"====== start failing test =========\n"}
    subject.decode(@buffer,@wf)
    @wf.must_equal(@field)
    Codec::Logger.debug {"====== end failing test =========\n"}
  end

  it "must generate buffer from composed field" do
    buff = ""
    subject.encode(buff, @field)
    buff.must_equal(@buffer)
  end  
end


describe Codec::Tlv do
  subject {
    tag = Codec::Binary.new(1)
    length = Codec::Numbin.new(1)
    value = Codec::Numbin.new(0)
    Codec::Tlv.new(length,tag,value) }
    before do
      @buffer = ["9501009C010181020200"].pack("H*")
      @field = Codec::Field.from_array('TAG',
        [['95',0],['9C',1],['81',512]])
      @wf = Codec::Field.new('TAG')
    end
    
    it "must decode TLV buffer to field" do
      subject.decode(@buffer,@wf)
      @wf.must_equal(@field)
    end
    
    it "must encode TLV field to buffer" do
      buff = ""
      subject.encode(buff, @field)
      buff.must_equal(@buffer)
    end
end
    
describe Codec::Bertlv do
  subject { Codec::Bertlv.new }
  
  before do
    @wf = Codec::Field.new('Bertlv')
    @tlv_buf = ["9F100A0102030405060708091095058000000000"].pack("H*")
    @field = Codec::Field.from_array('Bertlv',
              [['9F10','01020304050607080910'],['95','8000000000']])
  end

  it "must generate composed field from buffer" do
    subject.decode(@tlv_buf,@wf)
    @wf.must_equal(@field)
  end
  
  it "must generate buffer from composed field" do
    buff = ""
    subject.encode(buff, @field)
    buff.must_equal(@tlv_buf)
  end
end
