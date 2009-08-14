require 'test/unit'
require 'lib/iso8583'

class FieldTest < Test::Unit::TestCase



  def test_MMDDhhmmssCodec
    dt = MMDDhhmmssCodec.decode "1212121212"
    assert_equal DateTime, dt.class
    assert_equal 12, dt.month
    assert_equal 12, dt.day
    assert_equal 12, dt.hour
    assert_equal 12, dt.min
    assert_equal 12, dt.sec


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
      puts dt
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
      puts dt
    }
    
    assert_raise(ISO8583Exception) {
      dt = YYMMCodec.encode "0913"
    }

    assert_equal "0912", YYMMCodec.encode("0912")

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

  
end