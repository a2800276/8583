# Copyright 2009 by Tim Becker (tim.becker@kuriostaet.de)
# MIT License, for details, see the LICENSE file accompaning
# this distribution

require 'date'

module ISO8583

  # Codec provides functionality to encode and decode values, codecs are
  # used internally by Field instances in order to do character conversions
  # and checking for proper values.
  # Although they are used internally, you will probably need to write
  # your own Codec sooner or later. The codecs used by Field instances are
  # typically instances of Codec, it may or may not be usefull to subclass
  # Codec.
  # 
  # Say, for example, a text field needs to be encoded in EBCDIC in the
  # message, this is how a corresponding codec would be constructed:
  #
  #    EBCDIC_Codec = Codec.new
  #    EBCDIC_Codec.encoder = lambda {|ascii_str|
  #       raise ISO8583Exception.new("String (#{ascii_str})not valid!") unless =~ /someregexp/
  #       ascii2ebcdic ascii_str  # implementing ascii_str is left as an excercise
  #    }
  #    EBCDIC_Codec.decode = lambda {|ebcdic_str|
  #       # you may or may not want to raise exceptions at this point ....
  #       # strip removes any padding...
  #       ebcdic2ascii(ebcdic_str).strip
  #    }
  #
  # This instance of Codec would then be used be the corresponding Field
  # encoder/decoder, which may look similar to this:
  #
  #    EBCDIC         = Field.new
  #    EBCDIC.codec   = EBCDIC_Codec
  #    EBCDIC.padding = PADDING_LEFT_JUSTIFIED_SPACES
  #
  # Notice there is a bit of inconsistancy: the padding is added by the
  # field, but removed by the codec. I would like to find a better
  # solution to this...
  #
  # See also: Field, link:files/lib/fields_rb.html
  #
  # The following codecs are already implemented:
  # [+ASCII_Number+]      encodes either a Number or String representation of 
  #                       a number to the ASCII represenation of the number, 
  #                       decodes ASCII  numerals to a number
  # [+A_Codec+]           passes through ASCII string checking they conform to [A-Za-z]
  #                       during encoding, no validity check during decoding. 
  # [+AN_Codec+]          passes through ASCII string checking they conform to [A-Za-z0-9]
  #                       during encoding, no validity check during decoding. 
  # [+ANP_Codec+]         passes through ASCII string checking they conform to [A-Za-z0-9 ] 
  #                       during encoding, no validity check during decoding. 
  # [+ANS_Codec+]         passes through ASCII string checking they conform to [\x20-\x7E]
  #                       during encoding, no validity check during decoding.
  # [BE_U16]              16-bit unsigned, network (big-endian) byte order 
  # [BE_U32]              32-bit unsigned, network (big-endian) byte order  
  # [+Null_Codec+]        passes anything along untouched.
  # [<tt>Track2</tt>]     rudimentary check that string conforms to Track2
  # [+MMDDhhmmssCodec+]   encodes Time, Datetime or String to the described date format, checking 
  #                       that it is a valid date. Decodes to a DateTime instance, decoding and 
  #                       encoding perform validity checks!
  # [+MMDDCodec+]   encodes Time, Datetime or String to the described date format, checking 
  #                       that it is a valid date. Decodes to a DateTime instance, decoding and 
  #                       encoding perform validity checks!
  # [+YYMMDDhhmmssCodec+] encodes Time, Datetime or String to the described date format, checking 
  #                       that it is a valid date. Decodes to a DateTime instance, decoding and 
  #                       encoding perform validity checks!
  # [+YYMMCodec+]         encodes Time, Datetime or String to the described date format (exp date), 
  #                       checking that it is a valid date. Decodes to a DateTime instance, decoding
  #                       and encoding perform validity checks!
  #
  class Codec
    attr_accessor :encoder
    attr_accessor :decoder

    def decode(raw)
      decoder.call(raw)
    end

    # length is either a fixnum or a lenth encoder.
    def encode(value)
      encoder.call(value)
    end
  end

  # ASCII_Number
  ASCII_Number = Codec.new
  ASCII_Number.encoder= lambda{|num|
    enc = num.to_s
    raise ISO8583Exception.new("Invalid value: #{enc} must be numeric!") unless enc =~ /^[0-9]*$/
    enc
  }

  ASCII_Number.decoder = lambda{|raw|
    raw.to_i
  }

  PASS_THROUGH_DECODER = lambda{|str|
    str.strip # remove padding
  }

  # Takes a number or str representation of a number and BCD encodes it, e.g.
  # "1234" => "\x12\x34"
  # 3456   => "\x34\x56"
  #
  # right justified with null ... (correct to do this? almost certainly not...)
  Packed_Number = Codec.new
  Packed_Number.encoder = lambda { |val|
    val = val.to_s
    val = val.length % 2 == 0 ? val : "0"+val
    raise ISO8583Exception.new("Invalid value: #{val} must be numeric!") unless val =~ /^[0-9]*$/
    [val].pack("H*")
  }
  Packed_Number.decoder = lambda{|encoded|
    d = encoded.unpack("H*")[0].to_i
  }

  A_Codec = Codec.new
  A_Codec.encoder = lambda{|str|
    raise ISO8583Exception.new("Invalid value: #{str} must be [A-Za-z]") unless str =~ /^[A-Za-z]*$/
    str
  }
  A_Codec.decoder = PASS_THROUGH_DECODER

  AN_Codec = Codec.new
  AN_Codec.encoder = lambda{|str|
    raise ISO8583Exception.new("Invalid value: #{str} must be [A-Za-y0-9]") unless str =~ /^[A-Za-z0-9]*$/
    str
  }
  AN_Codec.decoder = PASS_THROUGH_DECODER

  ANP_Codec = Codec.new
  ANP_Codec.encoder = lambda{|str|
    raise ISO8583Exception.new("Invalid value: #{str} must be [A-Za-y0-9 ]") unless str =~ /^[A-Za-z0-9 ]*$/
    str
  }
  ANP_Codec.decoder = PASS_THROUGH_DECODER

  ANS_Codec = Codec.new
  ANS_Codec.encoder = lambda{|str|
    raise ISO8583Exception.new("Invalid value: #{str} must be [\\x20-\\x7E]") unless str =~ /^[\x20-\x7E]*$/
    str
  }
  ANS_Codec.decoder = PASS_THROUGH_DECODER
  
  BE_U16 = Codec.new
  BE_U16.encoder = lambda {|num|
    raise ISO8583Exception.new("Invalid value: #{num} must be 0<= X <=2^16-1") unless 0 <= num && num <= 2**16-1
    [num].pack("n")
  }
  BE_U16.decoder = lambda { |encoded|
    encoded.unpack("n")[0]
  }
  BE_U32 = Codec.new
  BE_U32.encoder = lambda {|num|
    raise ISO8583Exception.new("Invalid value: #{num} must be 0<= X <=2^32-1") unless 0 <= num && num <= 2**32-1
    [num].pack("N")
  }
  BE_U32.decoder = lambda { |encoded|
    encoded.unpack("N")[0]
  }

  Null_Codec = Codec.new
  Null_Codec.encoder = lambda {|str|
    str
  }
  Null_Codec.decoder = lambda {|str|
    str.gsub(/\000*$/, '')
  } 

  Track2 = Codec.new
  Track2.encoder = lambda{|track2|
    #SS | PAN | FS | Expiration Date | Service Code | Discretionary Data | ES | LRC
    # SS = ;
    # PAN = up to 19 digits (at least 9?)
    # FS = '='
    # Exp Date = YYMM
    # SC: 3 digits or =
    # ES = ?
    # lrc : 1byte
    raise ISO8583Exception.new("Invalid Track2 data: #{track2}") unless track2 =~ /^;*(\d{9,19})=(.*)\?.$/
    track2
  }
  Track2.decoder = PASS_THROUGH_DECODER

  def self._date_codec(fmt) 
    c = Codec.new
    c.encoder = lambda {|date|
      enc = case date
            when DateTime, Date, Time
              date.strftime(fmt)
            when String
              begin
                dt = DateTime.strptime(date, fmt)
                dt.strftime(fmt)
              rescue
                raise ISO8583Exception.new("Invalid format encoding: #{date}, must be #{fmt}.")
              end
            else  
              raise ISO8583Exception.new("Don't know how to encode: #{date.class} to a time.")
            end
      return enc
    }
    c.decoder = lambda {|str|
      begin
        DateTime.strptime(str, fmt)
      rescue
        raise ISO8583Exception.new("Invalid format decoding: #{str}, must be #{fmt}.")
      end
    }

    c
  end

  MMDDhhmmssCodec   = _date_codec("%m%d%H%M%S")
  HhmmssCodec       = _date_codec("%H%M%S")
  YYMMDDhhmmssCodec = _date_codec("%y%m%d%H%M%S")
  YYMMCodec         = _date_codec("%y%m")
  MMDDCodec         = _date_codec("%m%d")

end
