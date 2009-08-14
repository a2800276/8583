require 'date'

class Codec
  attr_accessor :encoder
  attr_accessor :decoder

  def decode raw
    return decoder.call(raw)
  end

  # length is either a fixnum or a lenth encoder.
  def encode value
    return encoder.call(value)
  end
end

ASCII_Number = Codec.new
ASCII_Number.encoder= lambda{|num|
  enc = num.to_s
  raise ISO8583Exception.new("Invalid value: #{enc} must be numeric!") unless enc =~ /^[0-9]*$/
  enc
}

ASCII_Number.decoder= lambda{|raw|
  raw.to_i
}

PASS_THROUGH_DECODER = lambda{|str|
  str.strip # remove padding
}

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
  raise ISO8583Exception.new("Invalid value: #{str} must be [\x20-\x7E]") unless str =~ /^[\x20-\x7E]*$/
  str
}
ANS_Codec.decoder = PASS_THROUGH_DECODER

Null_Codec = Codec.new
Null_Codec.encoder = lambda {|str|
  str
}
Null_Codec.decoder = lambda {|str|
  str.gsub(/\000*$/,'')
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

def _date_codec(fmt) 
  c = Codec.new
  c.encoder =  lambda {|date|
    enc = case date
        when Time
        when DateTime
          date.strftime(fmt)
        when String
          begin
            dt = DateTime.strptime date, fmt 
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
    dt =  begin
            DateTime.strptime str, fmt
          rescue
            raise ISO8583Exception.new("Invalid format decoding: #{str}, must be MMDDhhmmss.")
          end
    return dt
  }

  return c
end

MMDDhhmmssCodec   = _date_codec("%m%d%H%M%S") 
YYMMDDhhmmssCodec = _date_codec("%y%m%d%H%M%S")
YYMMCodec = _date_codec("%y%m")


