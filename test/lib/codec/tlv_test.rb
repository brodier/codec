require_relative '../../test_helper'
 
describe Codec::Tlv do
  subject { Codec::Tlv.new('Tlv', Codec::Numbin.new('*',1), 
              Codec::Binary.new('*',1), Codec::Binary.new('*',0))
          }
  
  before do
    @buffer = ["950580000000009C0100"].pack("H*")
    @field = Codec::Field.from_array('Tlv',[['95','8000000000'],['9C','00']])
  end

  it "must be a Tlv codec" do
    subject.must_be_instance_of(Codec::Tlv)
  end
  
  it "must generate composed field from buffer" do
    subject.decode(@buffer).first.
      must_equal(@field)
  end
end


describe Codec::Bertlv do
  subject { Codec::Bertlv.new('Bertlv') }
  
  before do
    @tlv_buf = ["9F100A0102030405060708091095058000000000"].pack("H*")
    @field = Codec::Field.from_array('Bertlv',
              [['9F10','01020304050607080910'],['95','8000000000']])
  end

  it "must be a Tlv codec" do
    subject.must_be_instance_of(Codec::Bertlv)
  end
  
  it "must generate composed field from buffer" do
    subject.decode(@tlv_buf).first.
      must_equal(@field)
  end
end
