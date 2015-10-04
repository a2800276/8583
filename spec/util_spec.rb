# encoding: binary
#

describe ISO8583, 'Utilities' do
	context 'hex2b' do
		it 'converts a well-formed hexadecimal value.' do
			expect(hex2b("abcd12")).to      eq("\xab\xcd\x12")
			expect(hex2b("a b c d 1 2")).to eq("\xab\xcd\x12")
			expect(hex2b("ABCD12")).to      eq("\xab\xcd\x12")
		end

		it 'fails with an +ISO8583::ISO8583Exception+ when a malformed hexadecimal value is passed.' do
			expect { hex2b("ABCDEFGH") }.to raise_error ISO8583::ISO8583Exception
		end

		it 'fails with an +ISO8583::ISO8583Exception+ when an odd hexadeciamal value is passed.' do
			expect { hex2b("ABCDEF0") }.to raise_error ISO8583::ISO8583Exception
		end
	end

	context 'b2hex' do
		it 'converts a string of bytes to a hexadecimal representation.' do
			expect(b2hex("\xab\xcd\x12")).to eq("abcd12")
		end
	end

	context 'ebcdic2ascii' do
		it 'converts an ebcdic string to ascii' do
			expect(ebcdic2ascii("\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9")).to eq("0123456789")
		end
	end

	context 'ascii2ebcdic' do
		it 'converts a string of ascii chars to ebcdic' do
			expect(ascii2ebcdic("0123456789")).to eq("\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9")
		end
	end

end
 
