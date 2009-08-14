

class Codec
  attr_accessor :encoder
  attr_accessor :decoder

  def decode raw
    return decoder.call(raw)
  end
  def encode value
    return encoder.call(value)
  end
end

ASCII_Number = Codec.new
ASCII_Number.encoder= lambda{|num|
  num.to_s
}
ASCII_Number.decoder= lambda{|raw|
  raw.to_i
}


