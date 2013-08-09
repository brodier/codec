require_relative '../../test_helper'
 
describe Codec::Numbin do
  subject { Codec::Numbin.new('Test',4) }

  before do
    @f256 = Codec::Field.new
    @f256.set_value(256)
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numbin)
  end
  
  it "must generate a field with computed value" do
    subject.decode(["00000100"].pack("H*")).first.get_value.to_i.must_equal(256)
  end
  
  it "must generate a field with computed value" do
    subject.decode(["00000100"].pack("H*")).last.size.must_equal(0)
  end

  it "must generate a field with computed value" do
    subject.encode(@f256).must_equal(["00000100"].pack("H*"))
  end
end

describe Codec::Numasc do
  subject { Codec::Numasc.new('Test',4) }
  
  before do
    @f12 = Codec::Field.new
    @f12.set_value(12)
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numasc)
  end
  
  it "must generate a field with computed value" do
    subject.decode("0012").first.get_value.to_i.must_equal(12)
  end
  
  it "must generate a field with computed value" do
    subject.decode("0012").last.size.must_equal(0)
  end

  it "must generate a field with computed value" do
    subject.encode(@f12).must_equal("0012")
  end
end

describe Codec::String do
  subject { Codec::String.new('Test',10) }
  before do
    @fstring = Codec::Field.new
    @fstring.set_value("TEST")
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::String)
  end
  
  it "must generate a field with computed value" do
    subject.decode("Testing string").first.get_value.must_equal("Testing st")
  end
  
  it "must also return remaining data" do
    subject.decode("Testing string").last.must_equal("ring")
  end

  it "must generate a buffer with corresponding value padded with space" do
    subject.encode(@fstring).must_equal("TEST      ")
  end
end

describe Codec::Binary do
  subject { Codec::Binary.new('Test',8) }
  before do
    @unpack_buffer = "ABCDEF0123456789"
    @bin_buffer = [@unpack_buffer].pack("H*")
    @fbin = Codec::Field.new
    @fbin.set_value(@unpack_buffer)
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Binary)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@bin_buffer).first.get_value.must_equal(@unpack_buffer)
  end
  
  it "must return no remaining data" do
    subject.decode(@bin_buffer).last.must_equal("")
  end

  it "must regenerate corresponding buffer" do
    subject.encode(@fbin).must_equal(@bin_buffer)
  end
end
