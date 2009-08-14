

class Bitmap

	
	# create a new Bitmap object. In case an iso message
	# is passed in, that messages bitmap will be parsed. If
	# not, this initializes and empty bitmap.

	def initialize message=nil
		@bmp = Array.new(128,false)
		if !message

		else
			initialize_from_message message
		end
	end
	
	# yield once with the number of each set field.
	def each
		@bmp.each_with_index {|set,i| yield i+i if set}
	end
	
	# returns whether the bit is set or not.
	def [] i
		@bmp[i-1]
	end

	# set the bit to the indicated value. Only `true` sets the
	# bit, any other value unsets it.
	def []= i,value
		if i > 128 
			raise ISO8583Exception.new("Bits > 128  are not permitted.")
		elsif i < 2
			raise ISO8583Exception.new("Bits < 2 are not permitted (continutation bit is set automatically)")
		end
		@bmp[i-1]=(value==true)
	end

	# sets bit #i
	def set i
		self[i]=true
	end
	
	# unsets bit #i
	def unset i
		self[i]=false
	end

	# generate the bytes representing this bitmap.
	def to_bytes
		arr=[self.to_s]
		# tricky and ugly, setting bit[1] only when generating to_s...
		count = self[1] ? 128 : 64
		arr.pack("B#{count}")
	end

	# generate a String representation of this bitmap in the form:
	#	01001100110000011010110110010100100110011000001101011011001010
	def to_s
		#check whether any `high` bits are set
		@bmp[0]=false
		65.upto(128) { |i| 
			if self[i]
		# if so, set continuation bit
				@bmp[0]=true
				break
			end
		}
		str = ""
		1.upto(self[1] ? 128 : 64) {|i|
			str << (self[i] ? "1" : "0")
		}
		str		
	end

private
	def initialize_from_message message
		bmp = message.unpack("B64")[0]
		if bmp[0,1] == "1"
			bmp = message.unpack("B128")[0]
		end
		
		0.upto(bmp.length-1) do |i|
			@bmp[i] = bmp[i,1]=="1"
		end

	
	end
	
end

if __FILE__==$0

	mp = ISO8583::Bitmap.new 
	20.step(128,7) {|i| mp.set(i)}
	print mp.to_bytes
end
