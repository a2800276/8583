require 'lib/iso8583'
require 'lib/berlin'
require 'test/unit'

class MessageTest < Test::Unit::TestCase
	def test_create_empty
	  mes = BerlinMessage.new
    mes.mti = 1100
    pan = 474747474747
    mes.pan = pan
    assert_equal pan, mes.pan
    assert_equal pan, mes[2]
    assert_equal pan, mes["Primary Account Number (PAN)"]
    assert_equal "1100@\000\000\000\000\000\000\00012474747474747", mes.to_b

    mes = BerlinMessage.new
    mes.mti = "Authorization Request Response Issuer Gateway"
    pan = 474747474747
    mes[2] = pan
    assert_equal pan, mes.pan
    assert_equal pan, mes[2]
    assert_equal pan, mes["Primary Account Number (PAN)"]
    assert_equal "1110@\000\000\000\000\000\000\00012474747474747", mes.to_b

    mes = BerlinMessage.new
    mes.mti = 1420
    pan = 474747474747
    mes["Primary Account Number (PAN)"] = pan
    assert_equal pan, mes.pan
    assert_equal pan, mes[2]
    assert_equal pan, mes["Primary Account Number (PAN)"]
    assert_equal "1420@\000\000\000\000\000\000\00012474747474747", mes.to_b
	end

	def test_parse
    pan = 474747474747

		assert_raises(ISO8583Exception) {
	    mes = BerlinMessage.parse "@\000\000\000\000\000\000\00012474747474747"
    }
	  mes = BerlinMessage.parse "1430@\000\000\000\000\000\000\00012474747474747"
    assert_equal pan, mes.pan
    assert_equal 1430, mes.mti
  end



end
	
