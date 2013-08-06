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
