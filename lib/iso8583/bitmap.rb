# Copyright 2009 by Tim Becker (tim.becker@kuriostaet.de)
# MIT License, for details, see the LICENSE file accompaning
# this distribution

module ISO8583

  # This class constructs an object for handling bitmaps
  # with which ISO8583 messages typically begin.
  # Bitmaps are either 8 or 16 bytes long, an extended length
  # bitmap is indicated by the first bit being set.
  # In all likelyhood, you won't be using this class much, it's used
  # transparently by the Message class.
  class Bitmap
    # create a new Bitmap object. In case an iso message
    # is passed in, that messages bitmap will be parsed. If
    # not, this initializes and empty bitmap.
    def initialize(message = nil, hex_bitmap=false)
      @bmp        = Array.new(128, false)
      @hex_bitmap = hex_bitmap

      message ? initialize_from_message(message) : nil
    end
    
    def hex_bitmap?
	    !!@hex_bitmap
    end

    # yield once with the number of each set field.
    def each #:yields: each bit set in the bitmap except the first bit.
      @bmp[1..-1].each_with_index {|set, i| yield i+2 if set}
    end
    
    # Returns whether the bit is set or not.
    def [](i)
      @bmp[i-1]
    end

    # Set the bit to the indicated value. Only `true` sets the
    # bit, any other value unsets it.
    def []=(i, value)
      if i > 128 
        raise ISO8583Exception.new("Bits > 128 are not permitted.")
      elsif i < 2
        raise ISO8583Exception.new("Bits < 2 are not permitted (continutation bit is set automatically)")
      end
      @bmp[i-1] = (value == true)
    end

    # Sets bit #i
    def set(i)
      self[i] = true
    end
    
    # Unsets bit #i
    def unset(i)
      self[i] = false
    end

    # Generate the bytes representing this bitmap.
    def to_bytes
      arr = [self.to_s]
      # tricky and ugly, setting bit[1] only when generating to_s...
      count = self[1] ? 128 : 64
      arr.pack("B#{count}")
    end
    alias_method :to_b, :to_bytes

    def to_hex
	    "%02x" % self.to_s.to_i(2)
    end

    # Generate a String representation of this bitmap in the form:
    #	01001100110000011010110110010100100110011000001101011011001010
    def to_s
      #check whether any `high` bits are set
      ret           = (65..128).one? {|bit| self[bit]}
      high, @bmp[0] = ret ? [128, true] : [64, false]

      str = ""
      1.upto(high) do|i|
	      str << (self[i] ? '1' : '0')
      end

      str
    end


    private

    def initialize_from_message(message)
      bmp = if hex_bitmap?
		    message[0..15].hex.to_s(2).rjust(64, '0')
	    else
		    message.unpack("B64")[0]
	    end

      if bmp[0,1] == "1"
	      bmp = if hex_bitmap?
			    message[0..31].hex.to_s(2).rjust(128,'0')
		    else
			    message.unpack("B128")[0]
		    end
      end

	0.upto(bmp.length-1) {|i| @bmp[i] = (bmp[i,1] == "1") }
    end

    class << self
      # Parse the bytes in string and return the Bitmap and bytes remaining in `str`
      # after the bitmap is taken away.
      def parse(str, hex_bitmap = false)
	bmp  = Bitmap.new(str, hex_bitmap)

	 rest = if bmp.hex_bitmap?
			 bmp[1] ? str[32, str.length] : str[16, str.length]
		else
			 bmp[1] ? str[16, str.length] : str[8, str.length]
		end

        [ bmp, rest ]
      end
    end
    
  end
end

if __FILE__==$0
  mp = ISO8583::Bitmap.new
  20.step(128,7) {|i| mp.set(i)}
  print mp.to_bytes
end
