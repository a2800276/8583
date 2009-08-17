require 'lib/iso8583'
require 'test/unit'

class UtilTest < Test::Unit::TestCase
	def test_hex2b
    assert_equal "\xab\xcd\x12", hex2b("abcd12")
    assert_equal "\xab\xcd\x12", hex2b("a b c d 1 2")
    assert_equal "\xab\xcd\x12", hex2b("ABCD12")
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
    assert_equal "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9", ascii2ebcdic("0123456789")
  end
end

