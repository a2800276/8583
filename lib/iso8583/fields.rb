#--
# Copyright 2009 by Tim Becker (tim.becker@kuriostaet.de)
# MIT License, for details, see the LICENSE file accompaning
# this distribution
#++

module ISO8583

  # This file contains a number of preinstantiated Field definitions. You
  # will probably need to create own fields in your implementation, please
  # see Field and Codec for further discussion on how to do this.
  # The fields currently available are those necessary to implement the 
  # Berlin Groups Authorization Spec.
  #
  # The following fields are available:
  #
  # [+LL+]           special form to de/encode variable length indicators, two bytes ASCII numerals
  # [+LLL+]          special form to de/encode variable length indicators, two bytes ASCII numerals
  # [+LL_BCD+]       special form to de/encode variable length indicators, two BCD digits
  # [+LLVAR_N+]      two byte variable length ASCII numeral, payload ASCII numerals
  # [+LLLVAR_N+]     three byte variable length ASCII numeral, payload ASCII numerals
  # [+LLVAR_Z+]      two byte variable length ASCII numeral, payload Track2 data 
  # [+LLVAR_AN+]    two byte variable length ASCII numeral, payload ASCII
  # [+LLVAR_ANS+]    two byte variable length ASCII numeral, payload ASCII+special
  # [+LLLVAR_AN+]   three byte variable length ASCII numeral, payload ASCII
  # [+LLLVAR_ANS+]   three byte variable length ASCII numeral, payload ASCII+special
  # [+LLVAR_B+]      Two byte variable length binary payload
  # [+LLLVAR_B+]     Three byte variable length binary payload
  # [+A+]            fixed length letters, represented in ASCII
  # [+N+]            fixed lengh numerals, repesented in ASCII, padding right justified using zeros
  # [+AN+]          fixed lengh ASCII [A-Za-z0-9], padding left justified using spaces.
  # [+ANP+]          fixed lengh ASCII [A-Za-z0-9] and space, padding left, spaces
  # [+ANS+]          fixed length ASCII  [\x20-\x7E], padding left, spaces
  # [+B+]            binary data, padding left using nulls (0x00)
  # [+MMDDhhmmss+]   Date, formatted as described in ASCII numerals
  # [+MMDD+]         Date, formatted as described in ASCII numerals
  # [+YYMMDDhhmmss+] Date, formatted as named in ASCII numerals
  # [+YYMM+]         Expiration Date, formatted as named in ASCII numerals
  # [+Hhmmss+]       Date, formatted in ASCII hhmmss


  # Special form to de/encode variable length indicators, two bytes ASCII numerals 
  LL         = Field.new
  LL.name    = "LL"
  LL.length  = 2
  LL.codec   = ASCII_Number
  LL.padding = lambda {|value|
    sprintf("%02d", value)
  }
  # Special form to de/encode variable length indicators, three bytes ASCII numerals
  LLL         = Field.new
  LLL.name    = "LLL"
  LLL.length  = 3
  LLL.codec   = ASCII_Number
  LLL.padding = lambda {|value|
    sprintf("%03d", value)
  }

  LL_BCD        = BCDField.new
  LL_BCD.length = 2
  LL_BCD.codec  = Packed_Number

  LLL_BCD_ANS        = VariableBCDField.new
  LLL_BCD_ANS.length = 3
  LLL_BCD_ANS.codec  = ANS_Codec


  # Two byte variable length ASCII numeral, payload ASCII numerals
  LLVAR_N        = Field.new
  LLVAR_N.length = LL
  LLVAR_N.codec  = ASCII_Number

  # Three byte variable length ASCII numeral, payload ASCII numerals
  LLLVAR_N        = Field.new
  LLLVAR_N.length = LLL
  LLLVAR_N.codec  = ASCII_Number

  # Two byte variable length ASCII numeral, payload Track2 data
  LLVAR_Z         = Field.new
  LLVAR_Z.length  = LL
  LLVAR_Z.codec   = Track2

  # Two byte variable length ASCII numeral, payload ASCII, fixed length, zeropadded (right)
  LLVAR_AN        = Field.new
  LLVAR_AN.length = LL
  LLVAR_AN.codec  = AN_Codec

  # Two byte variable length ASCII numeral, payload ASCII+special
  LLVAR_ANS        = Field.new
  LLVAR_ANS.length = LL
  LLVAR_ANS.codec  = ANS_Codec

  # Three byte variable length ASCII numeral, payload ASCII, fixed length, zeropadded (right)
  LLLVAR_AN        = Field.new
  LLLVAR_AN.length = LLL
  LLLVAR_AN.codec  = AN_Codec

  # Three byte variable length ASCII numeral, payload ASCII+special
  LLLVAR_ANS        = Field.new
  LLLVAR_ANS.length = LLL
  LLLVAR_ANS.codec  = ANS_Codec

  # Two byte variable length binary payload
  LLVAR_B        = Field.new
  LLVAR_B.length = LL
  LLVAR_B.codec  = Null_Codec


  # Three byte variable length binary payload
  LLLVAR_B        = Field.new
  LLLVAR_B.length = LLL
  LLLVAR_B.codec  = Null_Codec

  # Fixed lengh numerals, repesented in ASCII, padding right justified using zeros
  N = Field.new
  N.codec = ASCII_Number
  N.padding = lambda {|val, len| sprintf("%0#{len}d", val) }

  N_BCD = BCDField.new
  N_BCD.codec = Packed_Number

  N_BCD_PADDED         = BCDField.new
  N_BCD_PADDED.codec   = Packed_Number
  N_BCD_PADDED.padding = lambda {|val, len| 
	  delta = len - val.length

	  "\x00"*delta + val # padding left
  }

  PADDING_LEFT_JUSTIFIED_SPACES = lambda {|val, len| sprintf "%-#{len}s", val }

  # Fixed length ASCII letters [A-Za-z]
  A = Field.new
  A.codec = A_Codec

  # Fixed lengh ASCII [A-Za-z0-9], padding left justified using spaces.
  AN = Field.new
  AN.codec = AN_Codec
  AN.padding = PADDING_LEFT_JUSTIFIED_SPACES

  # Fixed lengh ASCII [A-Za-z0-9] and space, padding left, spaces
  ANP = Field.new
  ANP.codec = ANP_Codec
  ANP.padding = PADDING_LEFT_JUSTIFIED_SPACES

  # Fixed length ASCII  [\x20-\x7E], padding left, spaces
  ANS = Field.new
  ANS.codec = ANS_Codec
  ANS.padding = PADDING_LEFT_JUSTIFIED_SPACES

  # Binary data, padding left using nulls (0x00)
  B = Field.new
  B.codec = Null_Codec
  B.padding = lambda {|val, len|
    while val.length < len
      val = val + "\000"
    end
    val
  }

  # Date, formatted as described in ASCII numerals
  MMDDhhmmss        = Field.new
  MMDDhhmmss.codec  = MMDDhhmmssCodec
  MMDDhhmmss.length = 10

  #Date, formatted as described in ASCII numerals
  YYMMDDhhmmss        = Field.new
  YYMMDDhhmmss.codec  = YYMMDDhhmmssCodec
  YYMMDDhhmmss.length = 12

  #Date, formatted as described in ASCII numerals
  YYMM        = Field.new
  YYMM.codec  = YYMMCodec
  YYMM.length = 4
  
  MMDD        = Field.new
  MMDD.codec  = MMDDCodec
  MMDD.length = 4

  Hhmmss        = Field.new
  Hhmmss.codec  = HhmmssCodec
  Hhmmss.length = 6

end
