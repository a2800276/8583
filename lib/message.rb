
class BerlinMessage < Message
  bmp  2, "Primary Account Number (PAN)",               LLNVAR,    :max    => 19
  bmp  3,  "Processing Code",                           N,         :length =>  6
  bmp  4,  "Amount (Transaction)",                      N,         :length => 12
  bmp  6,  "Amount, Cardholder Billing" ,               N,         :length => 12
  bmp  7,  "Date and Time, Transmission"  ,             MMDDhhmmss
  bmp 10, "Conversion Rate, Cardholder Billing",        N,         :length =>  8
  bmp 11, "System Trace Audit Number (STAN)",           N,         :length =>  6
  bmp 12, "Date and Time, Local Transaction",           YYMMDDhhmmss
  bmp 14, "Date, Expiration",                           YYMM
  bmp 22, "POS Data Code",                              AN,        :length => 12
  bmp 23, "Card Sequence Number",                       N,         :length =>  3
  bmp 24, "Function Code",                              N,         :length =>  3
  bmp 25, "Message Reason Code",                        N,         :length =>  4
  bmp 26, "Card Acceptor Business Code",                N,         :length =>  4
  bmp 30, "Amounts, Original",                          N,         :length => 24
  bmp 32, "Acquiring Institution Identification Code",  LLVAR_N,   :max    => 11
  bmp 35, "Track 2 Data",                               LLVAR_Z,   :max    => 37
  bmp 37, "Retrieval Reference Number",                 ANP,       :length => 12
  bmp 38, "Approval Code",                              ANP,       :length =>  6
  bmp 39, "Action Code",                                N,         :length =>  3
  bmp 41, "Card Acceptor Terminal Identification",      ANS,       :length =>  8
  bmp 42, "Card Acceptor Identification Code",          ANS,       :length => 15
  bmp 43, "Card Acceptor Name/Location",                LLVAR_ANS, :max    => 56
  bmp 49, "Currency Code, Transaction",                 N,         :length =>  3
  bmp 51, "Currency Code, Cardholder Billing",          N,         :length =>  3
  bmp 52, "Personal Identification Number (PIN) Data",  B,         :length =>  8
  bmp 53, "Security Related Control Information",       LLVAR_B,   :max    => 48
  bmp 54, "Amounts, Additional",                        LLLVAR_ANS,:max    => 40

  bmp 55, "Integrated Circuit Card (ICC) System Related Data", LLLVAR_B,   :max    => 255
  bmp 56, "Original Data Elements",                            LLVAR_N,    :max    =>  35
  bmp 58, "Authorizing Agent Institution Identification Code", LLVAR_N,    :max    =>  11
  bmp 59, "Additional Data – Private",                         LLLVAR_ANS, :max    =>  67
  bmp 64, "Message Authentication Code (MAC) Field",           B,          :length =>   8
  
  bmp_alias  2, :pan
  bmp_alias  3, :proc_code
  bmp_alias  4, :amount
  bmp_alias 12, :exp_date
end

mes = BerlinMessage.new
mes[3] = 474747474747
mes["Processing Code"] = "123456"

pan = mes["Primary Account Number (PAN)"]
mes.pan = 47474747474747

mes2 = BerlinMessage.parse input

class BMP
  attr_accessor :bmp
  attr_accessor :name
  attr_accessor :field

  def initialize bmp, name, field
    @bmp   = bmp
    @name  = name
    @field = field
  end
end

class Message 

  def initialize
    @values = {}
  end

  def []= key, value
    bmp_def = _get_definition key  
    field.check(value)
    @values[bmp_def.bmp]= value
  end

  def [] key
    bmp_def = _get_definition key
    @values[bmp_def.bmp]
  end

  def to_b
    bitmap  = Bitmap.new
    message = ""
    @values.each_pair {|bmp, value|
      bmp_def = _get_definition(bmp)
      bitmap.set(bmp)
      
      field    = bmp_def.field.new(value)
      message << field.to_b
    }
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
      _handle_opts(field, opts) if opts
     
      b           = BMP.new(bmp, name, field)
      @defs[bmp]  = b
      @defs[name] = b
    end

    def bmp_alias bmp, aliaz
      
    end

    def definitions 
      @defs
    end

    def _handle_opts field, opts
      opts.each_pair {|key, value|
        if field.respond_to? key
          field.send(key, value)
        else
          warn "unknown option #{key} for #{field.name}"
        end
      }
    end
  end
end
