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

describe Codec::Field do
  subject { f = Codec::Field.new('Test')
    sf1 = Codec::Field.new('SF1')
    sf1.set_value("123")
    f.add_sub_field(sf1)
    sf2 = Codec::Field.new('SF2')
    sf2.set_value("321")
    f.add_sub_field(sf2)
    sf3 = Codec::Field.new('SF3')
    sf31 = Codec::Field.new('SF31')
    sf31.set_value("456")
    sf3.add_sub_field(sf31)
    sf32 = Codec::Field.new('SF32')
    sf32.set_value("789")
    sf3.add_sub_field(sf32)
    f.add_sub_field(sf3)
    f
  }
  
  it "must be a Field" do
    subject.must_be_instance_of(Codec::Field)
  end
  
  it "must respond to set_value" do
    subject.must_respond_to :set_value
  end
  
  it "must equal field create with from_array builder" do
    subject.must_equal(Codec::Field.from_array('Test',
    [['SF1',"123"],['SF2',"321"],['SF3',[['SF31',"456"],['SF32','789']]]]))
  end
  
end

describe Codec::Field do

  subject { f = Codec::Field.new('Test')
    sf1 = Codec::Field.new('SF1')
    sf1.set_value("123")
    f.add_sub_field(sf1)
    sf2 = Codec::Field.new('SF2')
    sf2.set_value("321")
    f.add_sub_field(sf2)
    sf3 = Codec::Field.new('SF3')
    sf31 = Codec::Field.new('SF31')
    sf31.set_value("456")
    sf3.add_sub_field(sf31)
    sf32 = Codec::Field.new('SF32')
    sf32.set_value("789")
    sf3.add_sub_field(sf32)
    f.add_sub_field(sf3)
    f
    [Codec::Field.from_array('Test',[['SF1',"123"],['SF2',"321"],
              ['SF3',[['SF31',"456"],['SF32','789']]]]),f]
  }
  
  it "must return one uniq element" do
    subject.uniq.size.must_equal(1)
  end
  
end