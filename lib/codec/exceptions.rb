module Codec
  class ParsingException < Exception
  end
  
  class EncodingException < Exception
  end

  class TooLongDataException < EncodingException
  end
  

  class InitializeException < Exception
  end
  
  class BufferUnderflow < ParsingException
  end

  class RaiminingData < ParsingException
  end
end