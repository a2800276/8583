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
      dt = A_Codec.encode "!!!"
    }
    assert_equal "bla", AN_Codec.encode("bla")
    assert_equal "bla", AN_Codec.decode("bla")
  end

  def test_AN_Codec
    assert_raise(ISO8583Exception) {
      dt = AN_Codec.encode "!!!"
    }
    assert_equal "bla", AN_Codec.encode("bla")
    assert_equal "bla", AN_Codec.decode("bla")
  end

  def test_Track2_Codec
    assert_raise(ISO8583Exception) {
      dt = Track2.encode "!!!"
    }
    assert_raise(ISO8583Exception) {
      dt = Track2.encode ";12312312=123?5"
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
      dt = Packed_Number.encode ";12312312=123?5"
    }
    assert_raise(ISO8583Exception) {
      dt = Packed_Number.encode "F"
    }
  end
end
