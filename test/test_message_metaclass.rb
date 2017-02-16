require 'lib/iso8583'
require 'test/unit'


class TestMessage < Message
    mti_format N, :length => 4
    mti 1100, "Authorization Request Acquirer Gateway"
end

class TestMessage2 < Message
    mti_format N_BCD, :length => 4
    mti 1100, "Authorization Request Acquirer Gateway"
end

class MessageMetaclassTest < Test::Unit::TestCase
  def test_mti
    t = TestMessage.new
    t.mti = 1100
    expected = "1100\0\0\0\0\0\0\0\0"
    bs = t.to_b
    assert_equal expected, bs
  end
  def test_len_prefix
    t = TestMessage2.new
    t.mti = 1100
    expected = "\x11\0\0\0\0\0\0\0\0\0"
    bs = t.to_b
    assert_equal expected, bs
  end
end
