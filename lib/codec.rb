require 'log4r'
require 'codec/version'
require 'codec/field'
require 'codec/exceptions'
require 'codec/base'
require 'codec/fix'
require 'codec/packed'
require 'codec/prefix'
# require 'codec/composed'


module Codec
  
  Logger = Log4r::Logger.new 'parserLog'
  Logger.outputters = Log4r::Outputter.stderr
  Logger.level=Log4r::INFO
  protocols = []
  
  if defined?(CODEC_CONST).nil?
    CODEC_CONST = true
  end
  
  
  def self.register_protocol(protocol)
    protocols << protocol
    return protocols
  end

end
