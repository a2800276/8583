LL         = Field.new
LL.length  = 2
LL.codec   = ASCII_Number
LL.padding = lambda { |value|
  sprintf("%02d", value)
}

LLL         = Field.new
LLL.length  = 3
LLL.codec   = ASCII_Number
LLL.padding = lambda { |value|
  sprintf("%03d", value)
}

LLVAR_N        = Field.new
LLVAR_N.length = LL
LLVAR_N.codec  = ASCII_Number

LLLVAR_N        = Field.new
LLLVAR_N.length = LLL
LLLVAR_N.codec  = ASCII_Number

LLVAR_Z         = Field.new
LLVAR_Z.length  = LL
LLVAR_Z.codec   = Track2

LLVAR_ANS       = Field.new
LLVAR_ANS.length= LL
LLVAR_ANS.codec = ANS_Codec

LLLVAR_ANS       = Field.new
LLLVAR_ANS.length= LLL
LLLVAR_ANS.codec = ANS_Codec

LLVAR_B       = Field.new
LLVAR_B.length= LL
LLVAR_B.codec = Null_Codec

LLLVAR_B       = Field.new
LLLVAR_B.length= LLL
LLLVAR_B.codec = Null_Codec

N = Field.new
N.codec = ASCII_Number
N.padding = lambda {|val, len|
  sprintf("%0#{len}d", val)
}

PADDING_LEFT_JUSTIFIED_SPACES = lambda {|val, len|
  sprintf "%-#{len}s", val
}

AN = Field.new
AN.codec = AN_Codec
AN.padding = PADDING_LEFT_JUSTIFIED_SPACES

ANP = Field.new
ANP.codec = ANP_Codec
ANP.padding = PADDING_LEFT_JUSTIFIED_SPACES

ANS = Field.new
ANS.codec = ANS_Codec
ANS.padding = PADDING_LEFT_JUSTIFIED_SPACES

B = Field.new
B.codec = Null_Codec
B.padding = lambda {|val, len|
  while val.length < len
    val = val + "\000"
  end
  val
}


MMDDhhmmss = Field.new
MMDDhhmmss.codec = MMDDhhmmssCodec

YYMMDDhhmmss = Field.new
YYMMDDhhmmss.codec = YYMMDDhhmmssCodec

YYMM = Field.new
YYMM.codec = YYMMCodec
