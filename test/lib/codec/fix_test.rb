require_relative '../../test_helper'
 
describe Codec::Numbin do
  subject { Codec::Numbin.new('Test',4) }
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numbin)
  end
  
  it "must generate a field with computed value" do
    subject.decode(["00000100"].pack("H*")).first.get_value.to_i.must_equal(256)
  end
  it "must generate a field with computed value" do
    subject.decode(["00000100"].pack("H*")).last.size.must_equal(0)
   end
end

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
    subject.encode(@f256).must_equal(["00000100"].pack("H*"))
  end
end

describe Codec::Numasc do
  subject { Codec::Numasc.new('Test',4) }
  
  it "must be a codec" do
    subject.must_be_instance_of(Codec::Numasc)
  end
  
  it "must generate a field with computed value" do
    subject.decode("0012").first.get_value.to_i.must_equal(12)
  end
  
  it "must generate a field with computed value" do
    subject.decode("0012").last.size.must_equal(0)
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
    subject.encode(@f12).must_equal("0012")
  end
end
