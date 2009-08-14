require 'test/unit'
require 'lib/iso8583'

class FieldTest < Test::Unit::TestCase



  def test_LLL
    value, rest = LLL.parse "123456"
    assert_equal 123, value
    assert_equal "456", rest

    assert_raise(ISO8583ParseException) {
      l,rest = LLL.parse "12"
    }
  end

  def test_LLNVAR
    value, rest = LLVAR_N.parse "021234"
    assert_equal 12, value
    assert_equal "34", rest

    value, rest = LLLVAR_N.parse "0041234"
    assert_equal 1234, value
    assert_equal "", rest
    assert_raise(ISO8583ParseException) {
      l,rest = LLLVAR_N.parse "12"
    }
    assert_raise(ISO8583ParseException) {
      l,rest = LLVAR_N.parse "12123"
    }
  end
  
end
