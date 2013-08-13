require_relative '../../test_helper'
 
describe Codec::BaseComposed do
  subject { Codec::BaseComposed.new('BaseComposed') }

  before do
    subject.add_sub_codec('CHP1', Codec::Numasc.new('CHP1',3))
    subject.add_sub_codec('CHP2', Codec::String.new('CHP2',5))
    subject.add_sub_codec('CHP3', Codec::String.new('CHP3',4))
    subject.add_sub_codec('CHP4', Codec::Numasc.new('CH4',4))
    field_array = [['CHP1',12],['CHP2','ABCDE'],['CHP3','WXYZ'],['CHP4',23]]
    @buffer_test1 = "012ABCDEWXYZ0023"
    @field_test1 = Codec::Field.from_array('BaseComposed', field_array)
    @buffer_test2 = "012ABCDEWXYZ"
    @field_test2 = Codec::Field.from_array('BaseComposed', field_array[0,3])
  end
  
  it "must be a BaseComposed codec" do
    subject.must_be_instance_of(Codec::BaseComposed)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@buffer_test1).first.must_equal(@field_test1)
  end

  it "must encode buffer with composed field" do
    subject.encode(@field_test1).must_equal(@buffer_test1)
  end
  
  it "must encode buffer with composed field without codec's last field " do
    subject.encode(@field_test2).must_equal(@buffer_test2)
  end  
  
  it "must handle remaining data" do
    subject.decode("012ABCDEWXYZ0023123").last.must_equal("123")
  end
end

describe Codec::CompleteComposed do
  subject { Codec::CompleteComposed.new('CompleteComposed') }

  before do
    test_1 = [['CHP1',Codec::Numasc.new('*',3),12],
      ['CHP2',Codec::String.new('*',5),"ABCDE"],
      ['CHP3',Codec::String.new('*',4),"WXYZ"]]
    field_array = test_1.collect{|id,codec,value| [id,value]}
    @field_1 = Codec::Field.from_array('CompleteComposed',field_array)
    test_1.each { |id,codec,value| subject.add_sub_codec(id,codec) }
    @buffer_1 = "012ABCDEWXYZ123"
    @buffer_2 = "012ABCDEWXYZ"
    @buffer_3 = "012ABCDE"
    @field_2 = Codec::Field.from_array('CompleteComposed',field_array[0,2])
  end
 
  it "must be a CompleteComposed codec" do
    subject.must_be_instance_of(Codec::CompleteComposed)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@buffer_1).first.must_equal(@field_1)
  end
  
  it "must handle remaining data" do
    subject.decode(@buffer_1).last.must_equal("123")
  end
 
  it "must raise BufferUnderflow if missing field" do
    proc { subject.decode(@buffer_3)}.must_raise(Codec::BufferUnderflow)
  end
  
  it "must encode expected buffer" do
    subject.encode(@field_1).must_equal(@buffer_2)
  end 

  it "must raise EncodingException if missing field" do
    proc { subject.encode(@field_2)}.must_raise(Codec::EncodingException)
  end

end