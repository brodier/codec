require_relative '../../test_helper'
 
describe Codec::Numbin do
  subject { Codec::Numbin.new(4) }

  before do
    @f256 = Codec::Field.new
    @f256.set_value(256)
  end
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numbin)
  end
  
  it "must generate a field with computed value" do
    f = Codec::Field.new
    subject.decode(["00000100"].pack("H*"),f)
    f.get_value.to_i.must_equal(256)
  end
  
  it "remaining buffer must be empty" do
    f = Codec::Field.new
    buf = ["00000100"].pack("H*")
    subject.decode(buf,f)
    buf.must_be_empty
  end

  it "must generate a field with computed value" do
    buf = ""
    subject.encode(buf, @f256)
    buf.must_equal(["00000100"].pack("H*"))
  end
end

describe Codec::Numasc do
  subject { Codec::Numasc.new(4) }
  
  before do
    @f12 = Codec::Field.new
    @f12.set_value(12)
  end
  
  it "must generate a field with computed value" do
    f = Codec::Field.new
    subject.decode("0012",f)
    f.get_value.must_equal(12)
  end
  
  it "remaining buffer must be empty" do
    buf = "0012"
    f = Codec::Field.new
    subject.decode(buf,f)
    buf.must_be_empty
  end

  it "must generate a field with computed value" do
    buf = ""
    subject.encode(buf, @f12)
    buf.must_equal("0012")
  end
end

describe Codec::String do
  subject { Codec::String.new(10) }
  
  it "must generate a field with computed value" do
    f = Codec::Field.new
    subject.decode("Testing string",f)
    f.get_value.must_equal("Testing st")
  end
  
  it "must also return remaining data" do
    buf = "Testing string"
    f = Codec::Field.new
    subject.decode(buf, f)
    buf.must_equal("ring")
  end

  it "must generate a buffer with corresponding value padded with space" do
    f = Codec::Field.new
    f.set_value("TEST")
    buf = ""
    subject.encode(buf, f)
    buf.must_equal("TEST      ")
  end
end

describe Codec::Binary do
  subject { Codec::Binary.new(8) }
  before do
    @unpack_buffer = "ABCDEF0123456789"
    @bin_buffer = [@unpack_buffer].pack("H*")
    @computed_f = Codec::Field.new
    @fbin = Codec::Field.new
    @fbin.set_value(@unpack_buffer)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@bin_buffer,@computed_f)
    @computed_f.get_value.must_equal(@unpack_buffer)
  end
  
  it "remaining buffer must be empty" do
    subject.decode(@bin_buffer,@computed_f)
    @bin_buffer.must_be_empty
  end

  it "must regenerate corresponding buffer" do
    buf = ""
    subject.encode(buf, @fbin)
    buf.must_equal(@bin_buffer)
  end
end
