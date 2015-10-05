# encoding: binary
#
require 'iso8583/berlin.rb'

describe ISO8583, '::Message' do
  context 'Message integrity' do
    it 'maintains the integrity of the fields if the MTI +value+ is used directly to build a message.' do
      mes = ISO8583::BerlinMessage.new
      pan = 474747474747

      mes.mti = 1100
      mes[2]  = pan

      expect(pan).to eq(mes[2])
      expect(mes.to_b).to eq("1100@\000\000\000\000\000\000\00012474747474747")
    end

    it 'maintains the integrity of the fields if the MTI +name+ is used directly to build a message.' do
      mes = ISO8583::BerlinMessage.new
      pan = 474747474747

      mes.mti = "Authorization Request Response Issuer Gateway"
      mes[2]  = pan

      expect(pan).to eq(mes[2])
      expect(mes.to_b).to eq("1110@\000\000\000\000\000\000\00012474747474747")
    end

    it "correclty relates the field's aliases to their values and names." do
      mes = ISO8583::BerlinMessage.new
      pan = 474747474747

      mes.mti = 1100
      mes["Primary Account Number (PAN)"] = pan

      expect(pan).to eq(mes["Primary Account Number (PAN)"])
      expect(mes.pan).to eq(mes[2])
    end

    it 'fails with a +ISO8583::ISO8583Exception+ if an unknown MTI value is used to build a message.' do
      mes = ISO8583::BerlinMessage.new
      expect { mes.mti = rand }.to raise_error ISO8583::ISO8583Exception
    end

    it 'fails with a +ISO8583::ISO8583Exception+ if an unknown +name+ is used to access the MTI value from a message.' do
      mes = ISO8583::BerlinMessage.new
      mes.mti = 1100

      expect { mes[rand.to_s] }.to raise_error ISO8583::ISO8583Exception
    end

    it 'handles multiple message types in one definition.' do
      mes = ISO8583::BerlinMessage.new
      pan = 474747474747

      mes.mti = 1420
      mes["Primary Account Number (PAN)"] = pan

      expect(pan).to eq(mes.pan)
      expect(pan).to eq(mes[2])
      expect(pan).to eq(mes["Primary Account Number (PAN)"])
      expect(mes.to_b).to eq("1420@\000\000\000\000\000\000\00012474747474747")
    end
  end

  context 'Message parsing' do
    it 'parses a defined and well-formed message.' do
      mes = ISO8583::BerlinMessage.parse "1430@\000\000\000\000\000\000\00012474747474747"

      pan = 474747474747

      expect(pan).to eq(mes.pan)
      expect(mes.mti).to eq(1430)
    end

    it 'fails to parse a well-formed but NOT DEFINED message with an +ISO8583::ISO8583Exception+ exception.' do
      payload = "9990@\000\000\000\000\000\000\00012474747474747"

      expect {ISO8583::BerlinMessage.parse(payload) }.to raise_error ISO8583::ISO8583Exception
    end

    it 'fails to parse a malformed message with an +ISO8583::ISO8583Exception+ exception.' do
      payload = "@\000\000\000\000\000\000\00012474747474747"

      expect { ISO8583::BerlinMessage.parse(payload) }.to raise_error ISO8583::ISO8583Exception
    end

    it 'ROUND TRIP. It parses back a message created by the class' do
      mes     = ISO8583::BerlinMessage.new

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
      mes2 = ISO8583::BerlinMessage.parse(mes.to_b)

      expect(mes.to_b).to eq(mes2.to_b)
    end
  end

  context 'Message string representation' do
    it 'produces a correct string representation of a message.' do
      mes     = ISO8583::BerlinMessage.new

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
    
      mes_str = <<-END
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
      expect(mes.to_s).to eq(mes_str)
    end
  end

  context 'Fields removal.' do

    it 'can remove fields from the message' do
      mes_1     = ISO8583::BerlinMessage.new
      mes_1.mti = "Network Management Request Response Issuer Gateway or Acquirer Gateway"
      mes_1[2]  = 474747474747

      mes_2 = ISO8583::BerlinMessage.parse(mes_1.to_b)
      expect(mes_2[2]).to eq(mes_1[2])

      mes_2[2] = nil

      mes_1     = ISO8583::BerlinMessage.new
      mes_1.mti = "Network Management Request Response Issuer Gateway or Acquirer Gateway"

      expect(mes_1.to_b).to eq(mes_2.to_b)
    end
  end

  context 'Required fields.' do

    class CustomMessage < ISO8583::Message
      include ISO8583

      mti_format N, :length => 4

      mti 1100, "Authorization Request Acquirer Gateway"

      bmp  2, "Primary Account Number (PAN)", LLVAR_N,   :max    => 19, :required => true
      bmp  3,  "Processing Code",             N,         :length =>  6
    end

    it 'fails with an +ISO8583::ISO8583MissingFieldException+ exception if a required field is not present.' do
      mes = CustomMessage.new
      mes.mti = 1100

      mes[3] = rand(1..10)
      expect {mes.to_b}.to raise_error ISO8583::ISO8583MissingFieldException
    end

    it 'does not fail if a required field is present.' do
      mes = CustomMessage.new
      mes.mti = 1100

      mes[2] = 474747474747
      mes[3] = rand(1..10)
      expect {mes.to_b}.not_to raise_error
    end
  end
end

