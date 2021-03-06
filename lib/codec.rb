require 'log4r'
require 'codec/version'
require 'codec/logger'
require 'codec/field'
require 'codec/exceptions'
require 'codec/eight_bits_encoding'
require 'codec/base'
require 'codec/fix'
require 'codec/packed'
require 'codec/prefix'
require 'codec/composed'
require 'codec/bitmap'
require 'codec/tlv'

module Codec
  # TODO : here implements Module constants and methods
  
  # method use to log deprecation warning
  def self.deprecated(msg)
    stack = Kernel.caller
    stack.shift
    Logger.warn "DEPRECATED: #{msg} | Call stack :
    #{stack.select{|l| l =~ /codec\/lib/}.each{|l| l}.join("\n")}"
  end
end
