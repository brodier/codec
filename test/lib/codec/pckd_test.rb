require_relative '../../test_helper'
 
describe Codec::Packed do
  subject { Codec::Packed.new('Test',6) }

  before do
    @f_pck = Codec::Field.new
    @f_pck.set_value("123")
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Packed)
  end
  
  it "must retrieve field length" do
    subject.get_length(@f_pck).must_equal(6)
  end

end

describe Codec::Numpck do
  subject { Codec::Numpck.new('Test',5) }
  
  before do
    @f12 = Codec::Field.new
    @f12.set_value(12)
    @pck_buff = ["000012"].pack("H*")
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numpck)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@pck_buff).first.get_value.to_i.must_equal(12)
  end
  
  it "must not remain data" do
    subject.decode(@pck_buff).last.size.must_equal(0)
  end

  it "must generate a field with computed value" do
    subject.encode(@f12).must_equal(@pck_buff)
  end
end

describe Codec::Strpck do
  subject { Codec::Strpck.new('Test',11) }
  before do
    @unpack_buffer = "497011D9010"
    @bin_buffer = [@unpack_buffer + "F"].pack("H*")
    @fbin = Codec::Field.new
    @fbin.set_value(@unpack_buffer)
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Strpck)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@bin_buffer).first.get_value.upcase.must_equal(@unpack_buffer)
  end
  
  it "must return no remaining data" do
    subject.decode(@bin_buffer).last.must_equal("")
  end

  it "must regenerate corresponding buffer" do
    subject.encode(@fbin).must_equal(@bin_buffer)
  end
end
