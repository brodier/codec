require_relative '../../test_helper'
 
describe Codec::Bitmap do
  
  subject { Codec::Bitmap.new('Bitmap',2) }
  
  before do
    subject.add_sub_codec('1',Codec::Numasc.new('*',3))
    subject.add_sub_codec('2', Codec::String.new('*',5))
    subject.add_sub_codec('3', Codec::String.new('*',3))
    subject.add_sub_codec('15', Codec::Numbin.new('*',2))
    @buffer = ["1100000000000010","012ABCDE","0012"].pack("B*A*H*")
  end

  it "must be a BaseComposed codec" do
    subject.must_be_instance_of(Codec::Bitmap)
  end
  
  it "must generate composed field from buffer" do
    subject.decode(@buffer).first.
      get_value.collect{ |id,f| 
        [id,f.get_value]
      }.must_equal([['1',12],['2',"ABCDE"],['15',18]])
  end

end

describe Codec::Bitmap do
  
  subject { Codec::Bitmap.new('MultipleBitmap',2) }
  
  before do
    subject.add_extended_bitmap('1')
    subject.add_sub_codec('2',Codec::Numasc.new('*',3))
    subject.add_sub_codec('3', Codec::String.new('*',5))
    subject.add_sub_codec('4', Codec::String.new('*',3))
    subject.add_sub_codec('18', Codec::Numbin.new('*',2))
    subject.add_sub_codec('21', Codec::String.new('*',5))
    @buffer_1 = ["11000000000000000100100000000000","012","0012","ABCDE"].pack("B*A*H*A*")
    @buffer2 = ["0110000000000000","012","ABCDE"].pack("B*A3A5")
    @field_1 = Codec::Field.from_array('MultipleBitmap',[['2',12],['18',18],['21',"ABCDE"]])
    @field_2 = Codec::Field.from_array('MultipleBitmap',[['2',12],['41',18],['21',"ABCDE"]])
  end

  it "must be a Bitmap codec" do
    subject.must_be_instance_of(Codec::Bitmap)
  end
  
  it "must generate composed field from buffer with extended bitmap" do
    subject.decode(@buffer_1).first.
      get_value.collect{ |id,f| 
        [id,f.get_value]
      }.must_equal([['2',12],['18',18],['21',"ABCDE"]])
  end

  it "must generate composed field from buffer without extended bitmap" do
    subject.decode(@buffer2).first.
      get_value.collect{ |id,f| 
        [id,f.get_value]
      }.must_equal([['2',12],['3',"ABCDE"]])
  end
  
  it "must generate buffer from composed field" do
    subject.encode(@field_1).must_equal(@buffer_1)
  end

  it "must raise Encoding exception if subfield is unknown" do
    proc { subject.encode(@field_2) }.must_raise(Codec::EncodingException)
  end  
  
end