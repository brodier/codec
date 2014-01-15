require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

require File.expand_path('../../lib/codec.rb', __FILE__)

Codec::Logger.outputters=Log4r::FileOutputter.new("Codec", {:filename => "rake_test.log"})