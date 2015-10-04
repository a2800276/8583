# encoding: binary
#

include ISO8583

describe ISO8583, 'Fields format' do
	context 'Defines the following fields' do
		it 'LLL' do
			value, rest = LLL.parse "123456"

			expect(value).to eq(123)
			expect(rest).to  eq('456')

			expect { LLL.parse "12" }.to raise_error ISO8583::ISO8583ParseException

			enc = LLL.encode 123
			expect(enc).to eq("\x31\x32\x33")

			enc = LLL.encode "123"
			expect(enc).to eq("\x31\x32\x33")

			enc = LLL.encode 12
			expect(enc).to eq("\x30\x31\x32")

			# enc = LLL.encode "012"
			# expect(enc).to eq("\x30\x31\x32")

			expect { LLL.encode 1234 }.to   raise_error ISO8583::ISO8583Exception

			expect { LLL.encode "1234" }.to raise_error ISO8583::ISO8583Exception
		end

		it 'LL_BCD' do
			value, rest = LL_BCD.parse "\x123456"
			expect(value).to eq(12)
			expect(rest).to  eq('3456')
		end

		it 'LLVAR_AN' do
			value, rest = LLVAR_AN.parse "03123ABC"
			expect(value).to eq('123')
			expect(rest).to  eq('ABC')

			value, rest = LLLVAR_AN.parse "006123ABC"
			expect(value).to eq('123ABC')
			expect(rest).to  eq('')

			expect { LLLVAR_AN.parse "12" }.to    raise_error ISO8583ParseException
			expect { LLLVAR_AN.parse "12123" }.to raise_error ISO8583ParseException

			enc = LLVAR_AN.encode "123A"
			expect(enc).to eq('04123A')

			enc = LLVAR_AN.encode "123ABC123ABC"
			expect(enc).to eq('12123ABC123ABC')

			
			expect { LLVAR_AN.encode "1234 ABCD" }.to raise_error ISO8583Exception

			enc = LLLVAR_AN.encode "123ABC123ABC"
			expect(enc).to eq('012123ABC123ABC')

			expect { LLLVAR_AN.encode "1234 ABCD" }.to raise_error ISO8583Exception
		end

		it 'LLVAR_N' do
			value, rest = LLVAR_N.parse '021234'
			expect(value).to eq(12)
			expect(rest).to eq('34')

			value, rest = LLLVAR_N.parse '0041234'
			expect(value).to eq(1234)
			expect('').to eq(rest)

			expect { LLLVAR_N.parse '12' }.to    raise_error ISO8583ParseException
			expect { LLLVAR_N.parse '12123' }.to raise_error ISO8583ParseException

			enc = LLVAR_N.encode 1234
			expect(enc).to eq('041234')

			enc = LLVAR_N.encode 123412341234
			expect(enc).to eq('12123412341234')

			expect { LLVAR_N.encode '1234ABCD' }.to raise_error ISO8583Exception

			enc = LLLVAR_N.encode '123412341234'
			expect(enc).to eq('012123412341234')

			expect { LLLVAR_N.encode '1234ABCD' }.to raise_error ISO8583Exception
		end

		it 'LLVAR_Z' do
			value, rest = LLVAR_Z.parse '16;123123123=123?5'+'021234'
			expect(value).to eq(';123123123=123?5')
			expect(rest).to  eq('021234')

			value, rest = LLVAR_Z.parse "16;123123123=123?5" 
			expect(value).to eq(';123123123=123?5')
			expect(rest).to  eq('')

			expect { LLVAR_Z.parse '12' }.to                raise_error ISO8583ParseException
			expect { LLVAR_Z.parse '17;123123123=123?5'}.to raise_error ISO8583ParseException

			enc = LLVAR_Z.encode ';123123123=123?5'
			expect(enc).to  eq('16;123123123=123?5')

			expect { LLVAR_Z.encode '1234ABCD' }.to raise_error ISO8583Exception
		end

		it 'A' do
			fld = A.dup
			fld.length = 3
			value, rest = fld.parse "abcd"
			expect(value).to  eq('abc')
			expect(rest).to eq("d")

			expect { fld.parse 'ab' }.to raise_error ISO8583ParseException

			expect { fld.encode 'abcdef' }.to raise_error ISO8583Exception
		end

		it 'AN' do
			fld = AN.dup
			fld.length = 3
			value, rest = fld.parse "1234"
			expect(value).to eq('123')
			expect(rest).to  eq('4')

			expect { fld.parse '12' }.to      raise_error ISO8583ParseException
			expect { fld.encode "888810" }.to raise_error ISO8583Exception
		end

		it 'ANP' do
			fld = ANP.dup
			fld.length = 3
			value, rest = fld.parse "1234"
			expect(value).to eq('123')
			expect(rest).to  eq('4')

			expect { fld.parse '12' }.to      raise_error ISO8583ParseException

			expect(fld.encode('10')).to eq('10 ')
		end

		it 'ANS' do
			fld = ANS.dup
			fld.length = 3
			value, rest = fld.parse "1234"
			expect(value).to eq('123')
			expect(rest).to  eq('4')

			expect { fld.parse '12' }.to      raise_error ISO8583ParseException

			expect(fld.encode('10')).to eq('10 ')
			expect(fld.parse("1! a")).to eq(["1!", "a"])
		end

		it 'B' do
			fld = B.dup
			fld.length = 3
			value, rest = fld.parse "\000234"
			expect(value).to eq("\00023")
			expect(rest).to  eq('4')

			expect { fld.parse '12' }.to      raise_error ISO8583ParseException

			expect(fld.encode("10")).to    eq("10\000")
			expect(fld.parse("1! a")).to   eq(["1! ", "a"])
			expect(fld.parse("1!\000")).to eq(["1!", ""])
		end


		it 'N_BCD' do
			fld = N_BCD.dup
			fld.length=3
			value, rest = fld.parse "\x01\x23\x45"
			expect(value).to eq(123)

			expect(fld.encode(123)).to    eq("\x01\x23")
			expect(fld.encode("123")).to  eq("\x01\x23")
			expect(fld.encode("0123")).to eq("\x01\x23")

			expect { fld.encode 12345 }.to raise_error ISO8583Exception

			# There's a bug here. A 4 digit value encodes to 2 digits encoded, 
			# which passes the test for length ... This test doesn't pass:

			# expect { fld.encode 1234 }.to raise_error ISO8583Exception
		end

		it 'YYMMDDhhmmss' do
			fld = YYMMDDhhmmss
			expect(fld.encode('740808120000')).to eq('740808120000')
		end

		it 'Hhmmss' do
			fld = Hhmmss
			expect(fld.encode("123456")).to eq('123456')
			dt, rest = fld.parse("123456")
			expect(dt.hour).to eq(12)
			expect(dt.min).to  eq(34)
			expect(dt.sec).to  eq(56)

			expect { fld.encode 1234567 }.to raise_error ISO8583Exception
		end
	end
end

