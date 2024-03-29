require 'lib/iso8583'
require 'test/unit'

include ISO8583

class BitmapTests < Test::Unit::TestCase
  def test_create_empty
    b = Bitmap.new
    assert_equal(b.to_s.size, 64, "proper length: 64")
    b.set(112)
    assert_equal(b.to_s.size, 128, "proper length: 128")
    assert_equal(b.to_s, "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000")
    b.unset(112)
    5.step(20,2){|i| b.set(i)}
    assert(b.to_s.size==64, "proper length: 64")
    assert_equal(b.to_s, "0000101010101010101000000000000000000000000000000000000000000000")
    assert b[5]
    assert b[7]
    assert b[11]
    assert !b[12]
    assert !b[199]

    assert_raises(ISO8583Exception) {b.set 1000 }
    assert_raises(ISO8583Exception) {	b.set 1 }
    assert_raises(ISO8583Exception) {	b.set(-1) }
  end

  def test_out_of_bounds_errors
    b = Bitmap.new
    assert_raises(ISO8583Exception) {b.set 1000 }
    assert_raises(ISO8583Exception) {	b.set 1 }
    assert_raises(ISO8583Exception) {	b.set(-1) }
  end

  def test_parse_bmp
    # 0000000001001001001001001001001001001001001001001001001001000000
    # generated by: 10.step(60,3) {|i| mp.set(i)}

    tst = "\x00\x49\x24\x92\x49\x24\x92\x40"
    b = Bitmap.new tst
    10.step(60,3) {|i| 
      assert(b[i], "bit #{i} is not set.")
      assert(!b[i+i], "bit #{i+i} is set.")
    }

    #10000000000000000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000
    # generated by: 20.step(128,7) {|i| mp.set(i)}
    tst = "\x80\x00\x10\x20\x40\x81\x02\x04\x08\x10\x20\x40\x81\x02\x04\x08"
    b = Bitmap.new tst
    20.step(128,7) {|i|
      assert(b[i], "bit #{i} is not set. (128 bit map)")
      assert(!b[i+i], "bit #{i+i} is set. (128 bit map)")
    }
  end

  def test_parse_rest
    tst = "\x00\x49\x24\x92\x49\x24\x92\x40\x31\x32\x33\x34"
    b, rest = Bitmap.parse tst
    10.step(60,3) {|i| 
      assert(b[i], "bit #{i} is not set.")
      assert(!b[i+i], "bit #{i+i} is set.")
    }
    assert_equal("1234", rest)
  end

  def test_each
    bmp = Bitmap.new
    bmp.set(2)
    bmp.set(3)
    bmp.set(5)
    bmp.set(6)
    arr = []
    bmp.each{|bit|
      arr.push bit
    }
    assert_equal [2,3,5,6], arr
  end

  def test_each_w_two_bitmaps_doesnt_yield_first_field
    #10000000000000000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000000100000010000001000
    # generated by: 20.step(128,7) {|i| mp.set(i)}
    tst = "\x80\x00\x10\x20\x40\x81\x02\x04\x08\x10\x20\x40\x81\x02\x04\x08"
    bmp = Bitmap.new tst
    arr = []
    bmp.each{|bit|
      arr.push bit
    }
    assert_equal 20, arr.first
  end
end

