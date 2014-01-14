require_relative '../../test_helper'
 
describe Codec::Packed do
  subject { Codec::Packed.new(6) }

  it "must retrieve field length" do
    f_pck = Codec::Field.new
    f_pck.set_value(123)  
    subject.get_length(@f_pck).must_equal(6)
  end

end

describe "Numeric packed" do
  subject { Codec::Packed.new(5) }
  
  before do
    @f12 = Codec::Field.new
    @f12.set_value(12)
    @f = Codec::Field.new
    @pck_buff = ["000012"].pack("H*")
  end
  
  it "must generate a field with computed value" do
    subject.decode(@pck_buff,@f)
    @f.get_value.must_equal(12)
  end
  
  it "remaining buffer must be empty" do
    subject.decode(@pck_buff,@f)
    @pck_buff.must_be_empty
  end

  it "must generate a field with computed value" do
    buf=""
    subject.encode(buf, @f12)
    buf.must_equal(@pck_buff)
  end
end

describe "Packed rigth padded with F" do
  subject { Codec::Packed.new(11,false,true,true) }
  before do
    @unpack_buffer = "497011D9010"
    @bin_buffer = [@unpack_buffer + "F"].pack("H*")
    @fbin = Codec::Field.new
    @fbin.set_value(@unpack_buffer)
    @f = Codec::Field.new
  end
  
  it "must generate a field with computed value" do
    subject.decode(@bin_buffer,@f)
    @f.get_value.upcase.must_equal(@unpack_buffer)
  end
  
  it "remaining buffer must be empty" do
    subject.decode(@bin_buffer,@f)
    @bin_buffer.must_be_empty
  end

  it "must regenerate corresponding buffer" do
    buf = ""
    subject.encode(buf, @fbin)
    buf.must_equal(@bin_buffer)
  end
end
