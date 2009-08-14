

class Codec
  def decode raw
    return raw
  end
  def encode value
    return value
  end
end

class ASCII_Number < Codec
  def decode raw
    return raw.to_i
  end

  def encode num
    num.to_s
  end
end
