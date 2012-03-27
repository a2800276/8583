require 'lib/iso8583'
require 'lib/iso8583/berlin'
require 'test/unit'

include ISO8583

class SeperateTest < Test::Unit::TestCase



def test_test_separate_messages
       mes1=BerlinMessage.new
       mes1[2]="1234567890"
       assert_equal(mes1[2], "1234567890")
       mes2=BerlinMessage.new
       mes2[2]="0987654321"
       assert_equal(mes2[2], "0987654321")
       # test that the original value of field 2 in mes1 hasn't changed
       assert_equal(mes1[2], "1234567890") # this will fail, as the field 2 in mes1 has changed value too!!
end

end
