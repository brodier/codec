# coding: utf-8
module Codec
  module EightBitsEncoding
    ASCII_EBCDIC = ["
    00010203372D2E2F1605250B0C0D0E0F101112133C3D322618193F271C1D1E1F
    405A7F7B5B6C507D4D5D5C4E6B604B61F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F
    7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6D7D8D9E2E3E4E5E6E7E8E94AE05A5F6D
    79818283848586878889919293949596979899A2A3A4A5A6A7A8A9C06AD0A107
    C3E4858181818183858585898989C1C1C50707969696A4A4A8D6E40707070707
    818996A495D5810707070707070707070707070707C1C1C10707070707070707
    07070707070781C10707070707070707070707070789C9C9C907070707070707
    D607D6D696D6070707E4E4E4A8E8070707070707070707070707070707070707
    ".gsub(/[^0-9a-fA-F]/i,'')].pack("H*")
    
    EBCDIC_ASCII = ["
    000102037F097F7F7F7F600B0C0DOE0F101112133C0A087F18197F7F1C1D1E1F
    7F7F7F7F7F0A171B7F7F7F7F7F0506077F7F167F7F7F7F047F7F7F7F14157F1A
    207F7F7F7F7F7F7F7F7F5B2E3C282B21267F7F7F7F7F7F7F7F7F21242A293B5E
    2D2F7F7F7F7F7F7F7F7F7C2C255F3E3F7F7F7F7F7F7F7F7F7F603A2340273D22
    7F6162636465666768697F7F7F7F7F7F7F6A6B6C6D6E6F7071727F7F7F7F7F7F
    7F7E737475767778797A7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F
    7B4142434445464748497F7F7F7F7F7F7D4A4B4C4D4E4F5051527F7F7F7F7F7F
    5C7F535455565758595A7F7F7F7F7F7F303132333435363738397F7F7F7F7F7F
    ".gsub(/[^0-9a-fA-F]/i,'')].pack("H*")
    
    ASCII_EXTENTION = (128..175).to_a + (224..255).to_a + 
      ["B5B6B7B8BDBEC6C7CFD0D1D2D3D4D5D6D7D8DE"].pack("H*").bytes.to_a
    UTF_8_EXTENTION = ["ÇÜéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®¬½¼¡«»",
      "ÓßÔÒõÕμþÞÚÛÙýÝ¯´-±_¾¶§÷¸°¨·¹³²_.", "ÁÂÀ©¢¥ãÃ¤ðÐÊËÈiÍÎÏÌ"].join.chars.to_a
    EXT_ASC_TO_UTF8 = Hash[ASCII_EXTENTION.zip(UTF_8_EXTENTION)]
    EXT_UTF8_TO_ASC = Hash[UTF_8_EXTENTION.zip(ASCII_EXTENTION)]
    
    def self.UTF8_2_ASCII(buf)
      buf.chars.each { |c| 
        if c.getbyte(0) < 128
          c
        elsif EXT_UTF8_TO_ASC[c].nil?
          127.chr
        else
          EXT_UTF8_TO_ASC[c].chr
        end
      }.join 
    end
    
    def self.ASCII_2_UTF8(buf)
      buf.bytes.each.collect { |b| 
        if b < 128
          b.chr
        elsif EXT_ASC_TO_UTF8[b].nil?
          127.chr # using ascii padding character
        else
          EXT_ASC_TO_UTF8[b]
        end
      }.join
    end
    
    def self.EBCDIC_2_UTF8(buf)
      ASCII_2_UTF8(buf.bytes.each.collect { |b| EBCDIC_ASCII.getbyte(b).chr }.join)
    end
    
    def self.UTF8_2_EBCDIC(buf)
      UTF8_2_ASCII(buf.bytes.each.collect { |b| EBCDIC_ASCII.getbyte(b).chr }.join)
    end
  end
end