module Codec
  Logger = Log4r::Logger.new 'codec_logger'
  Logger.outputters = Log4r::Outputter.stderr
  Logger.level=Log4r::INFO
end