require 'lib/iso8583'
require 'lib/berlin'
require 'test/unit'

include ISO8583

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

  def test_to_s
    mes     = BerlinMessage.new
    mes.mti = "Network Management Request Response Issuer Gateway or Acquirer Gateway" 
    mes[2]  = 12341234
    mes[3]  = 1111
    mes[4]  = 100
    mes[6]  = 101
    mes[7]  = "0808120000"
    mes[10] = 100
    mes[11] = 0
    mes[12] = "740808120000"
    mes[14] = "1010"
    mes[22] = "POSDATACODE"
    mes[23] = 0
    mes[24] = 1
    mes[25] = 90
    mes[26] = 4444
    mes[30] = 150
    mes[32] = 321321
    mes[35] = ";123123123=123?5"
    mes[37] = "123 123"
    mes[38] = "90"
    mes[39] = 90
    mes[41] = "TermLoc!"
    mes[42] = "ID Code!"
    mes[43] = "Card Acceptor Name Location"
    mes[49] = "840"
    mes[51] = 978
    mes[52] = '\x00\x01\x02\x03'
    mes[53] = '\x07\x06\x05\x04'
    mes[54] = "No additional amount"
    mes[55] = '\x07\x06\x05\x04'
    mes[56] = 88888888888
    mes[59] = "I'm you're private data, data for money..."
    mes[64] = "\xF0\xF0\xF0\xF0"
    
    expected = <<-END
MTI:1814 (Network Management Request Response Issuer Gateway or Acquirer Gateway)

002                      Primary Account Number (PAN) : 12341234
003                                   Processing Code : 1111
004                              Amount (Transaction) : 100
006                        Amount, Cardholder Billing : 101
007                       Date and Time, Transmission : 0808120000
010               Conversion Rate, Cardholder Billing : 100
011                  System Trace Audit Number (STAN) : 0
012                  Date and Time, Local Transaction : 740808120000
014                                  Date, Expiration : 1010
022                                     POS Data Code : POSDATACODE
023                              Card Sequence Number : 0
024                                     Function Code : 1
025                               Message Reason Code : 90
026                       Card Acceptor Business Code : 4444
030                                 Amounts, Original : 150
032         Acquiring Institution Identification Code : 321321
035                                      Track 2 Data : ;123123123=123?5
037                        Retrieval Reference Number : 123 123
038                                     Approval Code : 90
039                                       Action Code : 90
041             Card Acceptor Terminal Identification : TermLoc!
042                 Card Acceptor Identification Code : ID Code!
043                       Card Acceptor Name/Location : Card Acceptor Name Location
049                        Currency Code, Transaction : 840
051                 Currency Code, Cardholder Billing : 978
052         Personal Identification Number (PIN) Data : \\x00\\x01\\x02\\x03
053              Security Related Control Information : \\x07\\x06\\x05\\x04
054                               Amounts, Additional : No additional amount
055 Integrated Circuit Card (ICC) System Related Data : \\x07\\x06\\x05\\x04
056                            Original Data Elements : 88888888888
059                         Additional Data - Private : I'm you're private data, data for money...
064           Message Authentication Code (MAC) Field : \360\360\360\360
END
    assert_equal expected, mes.to_s
  end

  def test_round_trip
    mes     = BerlinMessage.new
    mes.mti = "Network Management Request Response Issuer Gateway or Acquirer Gateway" 
    mes[2]  = 12341234
    mes[3]  = 1111
    mes[4]  = 100
    mes[6]  = 101
    mes[7]  = "0808120000"
    mes[10] = 100
    mes[11] = 0
    mes[12] = "740808120000"
    mes[14] = "1010"
    mes[22] = "POSDATACODE"
    mes[23] = 0
    mes[24] = 1
    mes[25] = 90
    mes[26] = 4444
    mes[30] = 150
    mes[32] = 321321
    mes[35] = ";123123123=123?5"
    mes[37] = "123 123"
    mes[38] = "90"
    mes[39] = 90
    mes[41] = "TermLoc!"
    mes[42] = "ID Code!"
    mes[43] = "Card Acceptor Name Location"
    mes[49] = "840"
    mes[51] = 978
    mes[52] = "\x00\x01\x02\x03"
    mes[53] = "\x07\x06\x05\x04"
    mes[54] = "No additional amount"
    mes[55] = '\x07\x06\x05\x04'
    mes[56] = 88888888888
    mes[59] = "I'm you're private data, data for money..."
    mes[64] = "\xF0\xF0\xF0\xF0"

    bytes = mes.to_b
    mes2 = BerlinMessage.parse(mes.to_b)
    assert_equal(mes.to_b, mes2.to_b)
  end
end
