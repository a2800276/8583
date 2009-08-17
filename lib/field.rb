class Field
  # may either be some other Field in which the length is encoded or a Fixnum for
  # fixed length fields. Length should always be the length of the *encoded* value.
  # A 6 digit BCD field will require a length 3, as will a 5 digit BCD field.
  # The subclass BCDField handles this to keep things consistant.
  attr_accessor :length
  attr_accessor :codec
  attr_accessor :padding
  attr_accessor :max

  attr_writer   :name
  attr_accessor :bmp

  def name
    "BMP #{bmp}: #{@name}"
  end

  def parse raw
    len, raw = case length
               when Fixnum
                 [length, raw]
               when Field
                 length.parse(raw)
               else
                 raise ISO8583Exception.new("How did you manage to fuck up configuration this bad? <-")
               end

    raw_value  = raw[0,len]
    
    # make sure we have enough data ...
    if raw_value.length != len
      mes = "Field has incorrect length! field: #{raw_value} len/expected: #{raw_value.length}/#{len}"
      raise ISO8583ParseException.new(mes)
    end

    rest       = raw[len, raw.length]
    begin
      real_value = codec.decode(raw_value)
    rescue
      raise ISO8583ParseException.new($!.message+" (#{name})")
    end
    return real_value, rest
  end
  

  # Encoding needs to consider length representation, the actual encoding (such as charset or BCD) 
  # and padding. 
  # The order may be important! This impl calls codec.encode and then pads, in case you need the other 
  # special treatment, you may need to override this method alltogether.
  # In other cases, the padding has to be implemented by the codec, such as BCD with an odd number of nibbles.
  def encode value
    encoded_value = codec.encode(value) 
    
    
    if padding
      if padding.arity == 1
        encoded_value = padding.call(encoded_value)
      elsif padding.arity == 2
        encoded_value = padding.call(encoded_value, length)
      end
    end
    
    len_str = case length
              when Fixnum
                raise ISO8583Exception.new("Too long: #{value} (#{name})! length=#{length}")  if encoded_value.length > length
                raise ISO8583Exception.new("Too short: #{value} (#{name})! length=#{length}") if encoded_value.length < length
                "" 
              when Field
                raise ISO8583Exception.new("Max lenth exceeded: #{value}, max: #{max}") if max && encoded_value.length > max
                length.encode(encoded_value.length)
              else
                raise ISO8583Exception.new("How did you manage to fuck up configuration this bad? ->"+length)
              end
    return len_str + encoded_value
    
  end
end

class BCDField < Field
  # This corrects the length for BCD fields, as their encoded length is half (+ parity) of the
  # content length. E.g. 123 (length = 3) encodes to "\x01\x23" (length 2)
  def length
    _length = super
    (_length % 2) != 0 ?  (_length / 2)+1 : _length / 2
  end
end

#
#class Field
#  attr_accessor :value
#  
#  def initialize value=nil
#    @value = value
#  end
#  
#  def name
#    self.class._name
#  end
#  
#  def to_b
#    self.class.to_b @value
#  end
#
#  def to_s
#    "#{name} : #{value}"
#  end
#
#  class << self
#    def name name
#      @name = name
#    end
#    def _name
#      @name
#    end
#    def length len
#      @len = len
#    end
#
#    def _len
#      if (@len == nil) && (superclass.respond_to?(:_len))
#        return superclass.send(:_len)
#      end
#      @len
#    end
#
#    def min min
#      @min = min
#    end
#
#    def max max
#      @max = max
#    end
#    #def padding pad
#    #  @pad = pad
#    #end 
#    def codec codec
#      codec ||= Codec
#      @codec = codec
#      @codec = codec.new if codec.is_a? Class
#    end
#    
#    # tries to parse the 
#    def parse raw
#      l, rest = _get_len raw
#      #puts "len #{l}"
#      #puts "rest: #{rest}"
#      value = rest[0,l]
#
#      unless value.length == l
#        raise ISO8583ParseException.new "Wrong length for: #{value} (#{value.length}), expected #{l}" 
#      end
#
#      check(value)
#      
#
#      rest  = rest[l,rest.length] 
#      real_value = @codec.decode value
#      field = self.new real_value
#      return field, rest
#    end 
#
#    def to_b value
#      enc_value = @codec.encode(value)
#      enc_len   = 
#        case _len
#        when Fixnum
#          enc_value
#        when Field
#          _len.to_b(enc_value.length)
#
#    end
#
#    def check value
#      if @min && value.length < @min
#        raise ISO8583ParseException.new "Wrong length for: #{value}  (#{value.length}), min length #{@min}"
#      end
#      
#      if @max && value.length > @max
#        raise ISO8583ParseException.new "Wrong length for: #{value}  (#{value.length}), max length #{@max}"
#      end
#    end
#    
#    def _get_len raw
#      return _len, raw if _len.is_a? Fixnum
#      puts self.ancestors
#      puts _len
#      len_field, rest = _len.parse(raw)
#      return len_field.value, rest
#    end
#    
#
#  end
#end
#
