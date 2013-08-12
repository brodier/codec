require_relative '../../test_helper'

describe Codec::Prefixedlength do

  before do
    @length = Codec::Numasc.new('length',3)
    @content = Codec::String.new('content',0)
    @field = Codec::Field.new
    @field.set_value("0012AB")
    @buffer = "0060012AB"
  end

  subject { Codec::Prefixedlength.new('Test_lvar',@length,@content) }
  
  it "must be a Prefixedlength codec" do
    subject.must_be_instance_of(Codec::Prefixedlength)
  end
  
  it "must generate a field with computed value" do
    subject.decode(@buffer).first.get_value.must_equal("0012AB")
  end
  
  it "must also return remaining data" do
    subject.decode(@buffer).last.must_equal("")
  end

  it "must encode value prefixed with length" do
    subject.encode(@field).must_equal("0060012AB")
  end
end