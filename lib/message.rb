

class BMP
  
  attr_accessor :bmp
  attr_accessor :name
  attr_accessor :field
  attr_accessor :value

  def initialize bmp, name, field
    @bmp   = bmp
    @name  = name
    @field = field
  end
  def encode
    field.encode(value)
  end
end

class Message 

  attr_reader :mti 

  def initialize
    @values = {}
  end

  def mti= value
    num, name = _get_mti_definition(value)
    @mti = num
  end
  
  # set a field in this message, `key` is either the
  # bmp number or it's name.
  def []= key, value
    bmp_def              = _get_definition key
    bmp_def.value        = value
    @values[bmp_def.bmp] = bmp_def 
  end

  # retrieve the decoded value of a bitmap
  def [] key
    bmp_def = _get_definition key
    bmp     = @values[bmp_def.bmp]
    bmp ? bmp.value : nil
  end
  
  # retrieve the byte representation of the bitmap.
  def to_b
    raise ISO8583Exception.new "no MTI set!" unless mti
    mti_enc = self.class._mti_format.encode(mti)
    bitmap  = Bitmap.new
    message = ""
    @values.keys.sort.each{|bmp_num|
      bitmap.set(bmp_num)
      enc_value = @values[bmp_num].encode
      message << enc_value
    }
    mti_enc+bitmap.to_bytes + message
  end

  def _get_definition key
    b = self.class.definitions[key]
    unless b
      raise ISO8583Exception.new "no definition for field: #{key}"
    end
    b
  end

  # return [mti_num, mti_value] for key being either
  # mti_num or mti_value
  def _get_mti_definition key
    num_hash,name_hash = self.class.mti_definitions
    if    num_hash[key]
      [key, num_hash[key]]
    elsif name_hash[key]
      [name_hash[key], key]
    else
      raise ISO8583Exception.new("MTI: #{key} not allowed!")
    end
    
  end

  class << self
    
    # Define the allowed Message Types for the message.
    # Params:
    # field    : the decoder/encoder for the MTI
    def mti_format field, opts 
      f = field.dup
      _handle_opts(f, opts)
      @mti_format = f
    end

    def mti value, name
      @mtis_v ||= {}
      @mtis_n ||= {}
      @mtis_v[value] = name
      @mtis_n[name]  = value
    end

    # Define a bitmap in the message
    # params:
    # bmp   : bitmap number
    # name  : human readable form
    # field : field for encoding/decoding
    # opts  : options to pass to the field, e.g. length for fxed len fields.
    def bmp bmp, name, field, opts=nil
      @defs ||= {}

      field = field.dup
      field.name = name
      field.bmp  = bmp
      _handle_opts(field, opts) if opts
      
      bmp_def = BMP.new bmp, name, field

      @defs[bmp]  = bmp_def
      @defs[name] = bmp_def
    end
    
    # create an alias to access bitmaps directly using a method,
    # Example:
    #     bmp_alias 2, :pan
    #
    # would allow you to access the PAN like this:
    #
    #    mes.pan = 1234
    #    puts mes.pan
    #
    # instead of:
    #
    #    mes[2] = 1234
    #
    def bmp_alias bmp, aliaz
      define_method (aliaz) {
        bmp_ = @values[bmp]
        bmp_ ? bmp_.value : nil
      }

      define_method ("#{aliaz}=") { |value|
        self[bmp]=value
        #bmp_def = _get_definition(bmp)
        #bmp_def.value= value
        #@values[bmp] = bmp_def
      }
    end
    
    # parse `str` returnning a message of the defined type.
    def parse str
      message = self.new
      message.mti, rest = _mti_format.parse str
      bmp,rest = Bitmap.parse(rest)
      bmp.each {|bit|
        bmp_def     = definitions[bit]
        value, rest = bmp_def.field.parse(rest)
        message[bit] = value
      }
      return message
    end
    
    #
    # Access the field definitions of this class, this is a
    # hash containing [bmp_number, BMP] and [bitmap_name, BMP]
    # pairs.
    #
    def definitions 
      @defs
    end

    def mti_definitions
      [@mtis_v, @mtis_n]
    end

    def _mti_format
      @mti_format
    end

    def _handle_opts field, opts
      opts.each_pair {|key, value|
        key = (key.to_s+"=").to_sym
        if field.respond_to? key
          field.send(key, value)
        else
          warn "unknown option #{key} for #{field.name}"
        end
      }
    end
  end
end
