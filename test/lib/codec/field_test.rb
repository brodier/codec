require_relative '../../test_helper'
 
describe Codec::Field do
  subject { f = Codec::Field.new('Test')
    sf1 = Codec::Field.new('SF1')
    sf1.set_value("123")
    f.add_sub_field(sf1)
    sf2 = Codec::Field.new('SF2')
    sf2.set_value("321")
    f.add_sub_field(sf2)
    f
  }
  
  it "must be a Field" do
    subject.must_be_instance_of(Codec::Field)
  end
  
  it "must respond to set_value" do
    subject.must_respond_to :set_value
  end
  
  it "must equal field create with from_array builder" do
    subject.must_equal(Codec::Field.from_array('Test',[['SF1',"123"],['SF2',"321"]]))
  end

end
