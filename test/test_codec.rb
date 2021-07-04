require 'test/unit'
require 'lib/iso8583'

include ISO8583

class FieldTest < Test::Unit::TestCase
  def test_hhmmssCodec
    dt = HhmmssCodec.decode "121212"
    assert_equal DateTime, dt.class
    assert_equal 12, dt.hour
    assert_equal 12, dt.min
    assert_equal 12, dt.sec
    assert_equal DateTime, dt.class
    
    assert_raise(ISO8583Exception) {
      dt = HhmmssCodec.decode "261212"
    }
    assert_raise(ISO8583Exception) {
      dt = HhmmssCodec.encode "121261"
    }
    t = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
    assert_equal "020202", HhmmssCodec.encode(t)

  end
  def test_MMDDhhmmssCodec
    dt = MMDDhhmmssCodec.decode "1212121212"
    assert_equal DateTime, dt.class
    assert_equal 12, dt.month
    assert_equal 12, dt.day
    assert_equal 12, dt.hour
    assert_equal 12, dt.min
    assert_equal 12, dt.sec
    assert_equal DateTime, dt.class

    assert_raise(ISO8583Exception) {
      dt = MMDDhhmmssCodec.decode "1312121212"
    }
    
    assert_raise(ISO8583Exception) {
      dt = MMDDhhmmssCodec.encode "1312121212"
    }

    assert_equal "1212121212", MMDDhhmmssCodec.encode("1212121212")
  end

  def test_YYMMDDhhmmssCodec
    dt = YYMMDDhhmmssCodec.decode "081212121212"
    assert_equal DateTime, dt.class
    assert_equal 2008, dt.year
    assert_equal 12, dt.month
    assert_equal 12, dt.day
    assert_equal 12, dt.hour
    assert_equal 12, dt.min
    assert_equal 12, dt.sec

    assert_raise(ISO8583Exception) {
      dt = YYMMDDhhmmssCodec.decode "091312121212"
    }
    
    assert_raise(ISO8583Exception) {
      dt = YYMMDDhhmmssCodec.encode "091312121212"
    }

    assert_equal "091212121212", YYMMDDhhmmssCodec.encode("091212121212")
  end

  def test_YYMMCodec
    dt = YYMMCodec.decode "0812"
    assert_equal DateTime, dt.class
    assert_equal 2008, dt.year
    assert_equal 12, dt.month

    assert_raise(ISO8583Exception) {
      dt = YYMMCodec.decode "0913"
    }
    
    assert_raise(ISO8583Exception) {
      dt = YYMMCodec.encode "0913"
    }

    assert_equal "0912", YYMMCodec.encode("0912")
  end

  def test_YMMCodec
    dt = MMDDCodec.decode "0812"
    assert_equal DateTime, dt.class
    assert_equal 8, dt.month
    assert_equal 12, dt.day

    assert_raise(ISO8583Exception) {
      dt = MMDDCodec.decode "1313"
    }
    
    assert_raise(ISO8583Exception) {
      dt = MMDDCodec.encode "0231"
    }

    assert_equal "0912", MMDDCodec.encode("0912")
    t = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
    assert_equal "1031", MMDDCodec.encode(t)
  end
  def test_A_Codec
    assert_raise(ISO8583Exception) {
      A_Codec.encode "!!!"
    }
    assert_equal "bla", AN_Codec.encode("bla")
    assert_equal "bla", AN_Codec.decode("bla")
  end

  def test_AN_Codec
    assert_raise(ISO8583Exception) {
      AN_Codec.encode "!!!"
    }
    assert_equal "bla", AN_Codec.encode("bla")
    assert_equal "bla", AN_Codec.decode("bla")
  end

  def test_Track2_Codec
    assert_raise(ISO8583Exception) {
      Track2.encode "!!!"
    }
    assert_raise(ISO8583Exception) {
      Track2.encode ";12312312=123?5"
    }
    assert_equal ";123123123=123?5", Track2.encode(";123123123=123?5")
    assert_equal ";123123123=123?5", Track2.decode(";123123123=123?5")
  end

  def test_packed_codec
    assert_equal "\x12", Packed_Number.encode(12)
    assert_equal "\x12", Packed_Number.encode("12")
    assert_equal "\x02", Packed_Number.encode("2")
    assert_equal "\x02", Packed_Number.encode(2)
    assert_equal "\x02\x55", Packed_Number.encode(0xff)
    assert_raise(ISO8583Exception) {
      Packed_Number.encode ";12312312=123?5"
    }
    assert_raise(ISO8583Exception) {
      Packed_Number.encode "F"
    }
  end

  def test_BE_U16 
    assert_raise(ISO8583Exception) {
      BE_U16.encode 2**16
    }
    assert_raise(ISO8583Exception) {
      BE_U16.encode(-1)
    }
    assert_equal "\0\0", BE_U16.encode(0)
    expected = "\xff\xff".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U16.encode(2**16-1)
    expected = "\x0f\xf0".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U16.encode(0x00000ff0)
    expected = "\xf0\x0f".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U16.encode(0x0000f00f)
    expected = "\x5A\xA5".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U16.encode(0b0101101010100101)

    assert_equal 0x5aa5, BE_U16.decode(expected)
  end
  def test_BE_U32 
    assert_raise(ISO8583Exception) {
      BE_U32.encode 2**32
    }
    assert_raise(ISO8583Exception) {
      BE_U32.encode(-1)
    }
    assert_equal "\0\0\0\0", BE_U32.encode(0)
    expected = "\xff\xff\xff\xff".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U32.encode(2**32-1)
    expected = "\xf0\xf0\x0f\x0f".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U32.encode(0xf0f00f0f)
    expected = "\0\0\0\x1".force_encoding('ASCII-8BIT')
    assert_equal expected, BE_U32.encode(1)

    assert_equal 1, BE_U32.decode(expected)
    assert_equal 10, BE_U32.decode("\0\0\0\xa")
  end
end
