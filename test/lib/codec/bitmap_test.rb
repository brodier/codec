require_relative '../../test_helper'
 
describe Codec::Bitmap do
  
  subject { Codec::Bitmap.new(2) }
  
  before do
    subject.add_sub_codec('1',Codec::Numasc.new(3))
    subject.add_sub_codec('2', Codec::String.new(5))
    subject.add_sub_codec('3', Codec::String.new(3))
    subject.add_sub_codec('15', Codec::Numbin.new(2))
    @buffer = ["1100000000000010","012ABCDE","0012"].pack("B*A*H*")
    @field = Codec::Field.from_array('Bitmap',[['1',12],['2','ABCDE'],['15',18]])
  end

  it "must be a Bitmap codec" do
    subject.must_be_instance_of(Codec::Bitmap)
  end
  
  it "must generate composed field from buffer" do
    f = Codec::Field.new('Bitmap')
    subject.decode(@buffer, f).first.must_equal(@field)
  end

end

describe Codec::Bitmap do
  
  subject { Codec::Bitmap.new(2) }
  
  before do
    subject.add_extended_bitmap('1')
    subject.add_sub_codec('2',Codec::Numasc.new(3))
    subject.add_sub_codec('3', Codec::String.new(5))
    subject.add_sub_codec('4', Codec::String.new(3))
    subject.add_sub_codec('18', Codec::Numbin.new(2))
    subject.add_sub_codec('21', Codec::String.new(5))
    @buffer_1 = ["11000000000000000100100000000000","012","0012","ABCDE"].pack("B*A*H*A*")
    @buffer_2 = ["0110000000000000","012","ABCDE"].pack("B*A3A5")
    @field_1 = Codec::Field.from_array('test1',[['2',12],['18',18],['21',"ABCDE"]])
    @field_2 = Codec::Field.from_array('test2',[['2',12],['3','ABCDE']])
    @field_3 = Codec::Field.from_array('test3',[['2',12],['41',18],['21',"ABCDE"]])
  end

  it "must be a Bitmap codec" do
    subject.must_be_instance_of(Codec::Bitmap)
  end
  
  it "must generate composed field from buffer with extended bitmap" do
    f1 = Codec::Field.new('test1')
    subject.decode(@buffer_1,f1).first.must_equal(@field_1)
  end

  it "must generate composed field from buffer without extended bitmap" do
    f2 = Codec::Field.new('test2')
    subject.decode(@buffer_2,f2).first.must_equal(@field_2)
  end
  
  it "must generate buffer from composed field" do
    buf1 = ""
    subject.encode(buf1, @field_1)
    buf1.must_equal(@buffer_1)
  end

  it "must raise Encoding exception if subfield is unknown" do
    buf = ""
    proc { subject.encode(buf, @field_3) }.must_raise(Codec::EncodingException)
  end  
  
end
