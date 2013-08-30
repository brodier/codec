# coding: utf-8
require_relative '../../test_helper'
 
describe Codec::Ascii do

  subject { Codec::Ascii.new('test',3) }
  
  it "must be a Codec::Ascii" do
    subject.must_be_instance_of(Codec::Ascii)
  end
  
  it "must encode field from utf-8 to ascii" do
    subject.encode(Codec::Field.new('test','été')).must_equal(["827482"].pack("H*"))
  end

  it "must decode from ascii stream to utf-8 field" do
    subject.decode(["827482"].pack("H*")).first.must_equal(Codec::Field.new('test','été'))
  end

end

describe Codec::Ebcdic do

  subject { Codec::Ebcdic.new('test',3) }
  
  it "must be a Codec::Ebcdic" do
    subject.must_be_instance_of(Codec::Ebcdic)
  end
  
  it "must encode field from utf-8 to Ebcdic" do
    subject.encode(Codec::Field.new('test','été')).must_equal(["85A385"].pack("H*"))
  end

  it "must decode from Ebcdic stream to utf-8 field" do
    subject.decode(["85A385"].pack("H*")).first.must_equal(Codec::Field.new('test','ete'))
  end

end