

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

  def initialize
    @values = {}
  end

  def []= key, value
    bmp_def              = _get_definition key
    bmp_def.value        = value
    @values[bmp_def.bmp] = bmp_def 
  end

  def [] key
    bmp_def = _get_definition key
    bmp     = @values[bmp_def.bmp]
    bmp ? bmp.value : nil
  end

  def to_b
    bitmap  = Bitmap.new
    message = ""
    @values.keys.sort.each{|bmp_num|
      bitmap.set(bmp_num)
      
       
      enc_value = @values[bmp_num].encode
      message << enc_value
    }
    bitmap.to_bytes + message
  end

  def _get_definition key
    b = self.class.definitions[key]
    unless b
      raise ISO8583Exception.new "no definition for field: #{key}"
    end
    b
  end

  class << self
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

    def bmp_alias bmp, aliaz
      define_method (aliaz) {
        bmp = @values[bmp]
        bmp ? bmp.value : nil
      }

      define_method ("#{aliaz}=") { |value|
        bmp_def = _get_definition(bmp)
        bmp_def.value= value
        @values[bmp] = bmp_def
      }
    end

    def definitions 
      @defs
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
