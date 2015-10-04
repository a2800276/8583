# encoding: binary
#

describe ISO8583, 'Message integrity check' do
	context 'Separate messages' do
		it '' do
			mes1    = BerlinMessage.new
			mes1[2] = "1234567890"
			expect("1234567890").to eq(mes1[2])

			mes2    = BerlinMessage.new
			mes2[2] = "0987654321"
			expect("0987654321").to eq(mes2[2])

			# test that the original value of field 2 in mes1 hasn't changed
			expect("1234567890").to eq(mes1[2])
		end
	end
end

