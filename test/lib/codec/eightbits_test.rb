# coding: utf-8
require_relative '../../test_helper'
 
describe Codec::Ascii do

  subject { Codec::Ascii.new(3) }
  
  it "must encode field from utf-8 to ascii" do
    f = Codec::Field.new('test','été')
    buff =""
    subject.encode(buff, f)
    buff.must_equal(["827482"].pack("H*"))
  end

  it "must decode from ascii stream to utf-8 field" do
    buff = ["827482"].pack("H*")
    f = Codec::Field.new('test')
    subject.decode(buff,f)
    f.must_equal(Codec::Field.new('test','été'))
  end

end

describe Codec::Ebcdic do

  subject { Codec::Ebcdic.new(3) }
  
  it "must encode field from utf-8 to Ebcdic" do
    f = Codec::Field.new('test','été')
    buff =""
    subject.encode(buff, f)
    buff.must_equal(["85A385"].pack("H*"))
  end

  it "must decode from Ebcdic stream to utf-8 field" do
    buff = ["85A385"].pack("H*")
    f = Codec::Field.new('test')
    subject.decode(buff, f)
    f.must_equal(Codec::Field.new('test','ete'))
  end

end