# encoding: binary
#

include ISO8583

describe ISO8583, 'Codecs' do
	context 'Defines the following codecs' do
		it 'HhmmssCodec' do
			dt = HhmmssCodec.decode "121212"
			expect(dt.class).to eq(DateTime)
			expect(dt.hour).to  eq(12)
			expect(dt.min).to   eq(12)
			expect(dt.sec).to   eq(12)

			expect { HhmmssCodec.decode '261212' }.to raise_error ISO8583Exception
			expect { HhmmssCodec.decode '121261' }.to raise_error ISO8583Exception

			t = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
			expect(HhmmssCodec.encode(t)).to eq("020202")
		end

		it 'MMDDhhmmssCodec' do
			dt = MMDDhhmmssCodec.decode "1212121212"
			expect(dt.class).to eq(DateTime)
			expect(dt.month).to eq(12)
			expect(dt.day).to   eq(12)
			expect(dt.hour).to  eq(12)
			expect(dt.min).to   eq(12)
			expect(dt.sec).to   eq(12)

			expect { MMDDhhmmssCodec.decode "1312121212" }.to raise_error ISO8583Exception
			expect { MMDDhhmmssCodec.encode "1312121212" }.to raise_error ISO8583Exception

			expect(MMDDhhmmssCodec.encode("1212121212")).to eq("1212121212")
		end

		it 'YYMMDDhhmmssCodec' do
			dt = YYMMDDhhmmssCodec.decode "081212121212"
			expect(dt.class).to eq(DateTime)
			expect(dt.year).to  eq(2008)
			expect(dt.month).to eq(12)
			expect(dt.day).to   eq(12)
			expect(dt.hour).to  eq(12)
			expect(dt.min).to   eq(12)
			expect(dt.sec).to   eq(12)

			expect { YYMMDDhhmmssCodec.decode "091312121212" }.to raise_error ISO8583Exception
			expect { YYMMDDhhmmssCodec.encode "091312121212" }.to raise_error ISO8583Exception

			expect(YYMMDDhhmmssCodec.encode("091212121212")).to eq("091212121212")
		end

		it 'YYMMCodec' do
			dt = YYMMCodec.decode "0812"
			expect(dt.class).to eq(DateTime)
			expect(dt.year).to  eq(2008)
			expect(dt.month).to eq(12)

			expect { YYMMCodec.decode "0913" }.to raise_error ISO8583Exception
			expect { YYMMCodec.encode "0913" }.to raise_error ISO8583Exception

			expect(YYMMCodec.encode("0912")).to eq("0912")
		end

		it 'YMMCodec' do
			dt = MMDDCodec.decode "0812"
			expect(dt.class).to eq(DateTime)
			expect(dt.month).to eq(8)
			expect(dt.day).to   eq(12)

			expect { MMDDCodec.decode "1313" }.to raise_error ISO8583Exception
			expect { MMDDCodec.encode "1313" }.to raise_error ISO8583Exception

			expect(MMDDCodec.encode("0912")).to eq("0912")
			t = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
			expect(MMDDCodec.encode(t)).to eq("1031")
		end

		it 'A_Codec' do
			expect { A_Codec.encode "!!!" }.to raise_error ISO8583Exception

			expect(A_Codec.decode("bla")).to eq("bla")
			expect(A_Codec.encode("bla")).to eq("bla")
		end

		it 'AN_Codec' do
			expect { AN_Codec.encode "!!!" }.to raise_error ISO8583Exception

			expect(AN_Codec.encode("bla")).to eq("bla")
			expect(AN_Codec.decode("bla")).to eq("bla")
		end

		it 'Track2_Codec' do
			expect { Track2.encode "!!!" }.to             raise_error ISO8583Exception
			expect { Track2.encode ";12312312=123?5" }.to raise_error ISO8583Exception

			expect(Track2.encode(";123123123=123?5")).to eq(";123123123=123?5")
			expect(Track2.decode(";123123123=123?5")).to eq(";123123123=123?5")
		end

		it 'packed_codec' do
			expect(Packed_Number.encode(12)).to   eq("\x12")
			expect(Packed_Number.encode("12")).to eq("\x12")
			expect(Packed_Number.encode("2")).to  eq("\x02")
			expect(Packed_Number.encode(2)).to    eq("\x02")
			expect(Packed_Number.encode(0xff)).to eq("\x02\x55")

			expect { Packed_Number.encode ";12312312=123?5" }.to raise_error ISO8583Exception

			expect { Packed_Number.encode "F" }.to raise_error ISO8583Exception
		end
	end
end



