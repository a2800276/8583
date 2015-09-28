require 'lib/iso8583'
require 'test/unit'

include ISO8583

class UtilTest < Test::Unit::TestCase
  def test_hex2b
    # weird ruby 2.0 workaround:
    # literal:
    #   "\xab\xcd\x12"
    # is interpretted as:
    #   "\xAB\xCD\u0012"
    # ...force_encoding(...) fixes this.

    expected = "\xab\xcd\x12".force_encoding("ASCII-8BIT")

    assert_equal expected, hex2b("abcd12")
    assert_equal expected, hex2b("a b c d 1 2")
    assert_equal expected, hex2b("ABCD12")
    assert_raise(ISO8583Exception){
      # non hex
      hex2b("ABCDEFGH")
    }
    assert_raise(ISO8583Exception){
      # odd num digits
      hex2b("ABCDEF0")
    }
  end

  def test_b2hex
    assert_equal "abcd12", b2hex("\xab\xcd\x12")
  end

  def test_ebcdic2ascii
    assert_equal "0123456789", ebcdic2ascii("\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9")
  end

  def test_ascii2ebcdic
    assert_equal "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9".force_encoding('ASCII-8BIT'), ascii2ebcdic("0123456789")
  end
end
