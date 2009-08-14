require 'test/unit'
require 'lib/iso8583'

class FieldTest < Test::Unit::TestCase
  class FFF < Field
    name "Tim"
    length 3
  end

  class MinMax < LLNVAR
    name :MinMax
    min 5
    max 7
  end

  def test_field
    f = FFF.new :test
    assert_equal "Tim", f.name
  end

  def test_LLL
    l, rest = LLL.parse "123456"
    assert_equal 123, l.value
    assert_equal "456", rest

    assert_raise(ISO8583ParseException) {
      l,rest = LLL.parse "12"
    }
    assert_equal 123, l.value
  end

  def test_LLNVAR
    l, rest = LLNVAR.parse "021234"
    assert_equal 12, l.value
    assert_equal "34", rest

    l, rest = LLLNVAR.parse "0041234"
    assert_equal 1234, l.value
    assert_equal "", rest
    assert_raise(ISO8583ParseException) {
      l,rest = LLLNVAR.parse "12"
    }
    assert_raise(ISO8583ParseException) {
      l,rest = LLNVAR.parse "12123"
    }
  end
  
  def test_min_max
    l, rest = MinMax.parse "05123456"
    assert_equal 12345, l.value
    assert_equal 6, rest
  end
end
