# encoding: binary
# Copyright 2009 by Tim Becker (tim.becker@kuriostaet.de)
# MIT License, for details, see the LICENSE file accompaning
# this distribution

module ISO8583

=begin
	The class `Message` defines functionality to describe classes
	representing different type of messages, or message families.
	A message family consists of a number of possible message types that
	are allowed, and a way of naming and encoding the bitmaps allowed in
	the messages.

	To create your own message, start by subclassing Message:

		class MyMessage < Message
			(...)
		end

	the subtyped message should be told how the MTI is encoded:

		class MyMessage < Message
			mti_format N, :length => 4
			(...)
		end

	`N` above is an instance of Field which encodes numbers into their
	ASCII representations in  a fixed length field. The option `length=>4`
	indicates the length of the fixed field.

	Next, the allowed message types are specified:

		class MyMessage < Message
			(...)
			mti 1100, "Authorization Request Acquirer Gateway"
			mti 1110, "Authorization Request Response Issuer Gateway"
			(...)
		end

	This basically defines to message types, 1100 and 1110 which may
	be accessed later either via their name or value:

		mes = MyMessage.new 1100

	or
		mes = MyMessage.new "Authorization Request Acquirer Gateway"

	or
		mes = MyMessage.new
		mes.mti = 1110 # or Auth. Req. Acq. Gateway ...

	Finally the allowed bitmaps, their names and the encoding rules are
	specified:

		class MyMessage < Message
			(...)
			bmp  2, "Primary Account Number (PAN)",     LLVAR_N,   :max    => 19
			bmp  3,  "Processing Code",                 N,         :length =>  6
			bmp  4,  "Amount (Transaction)",            N,         :length => 12
			bmp  6,  "Amount, Cardholder Billing" ,     N,         :length => 12
			(...)
		end

	The example above defines four bitmaps (2,3,4 and 6), and provides
	their bitmap number and description. The PAN field is variable length
	encoded (LL length indicator, ASCII, contents numeric, ASCII) and the
	maximum length of the field is limited to 19 using options.

	The other fields are fixed length numeric ASCII fields (the length of the fields is
	indicated by the `:length` options.)

	This message may be used as follows in order to interpret a received message.:

	mes = MyMessage.parse inputData
	puts mes[2] # prints the PAN from the message.

	Constructing own messages works as follows:

		mes = MyMessage.new 1100 
		mes[2]= 474747474747

		# Alternatively
		mes["Primary Account Number (PAN)"]= 4747474747

		mes[3] = 1234 # padding is added by the Field en/decoder
		mes["Amount (Transaction)"] = 100
		mes[6] = 200

	the convenience method bmp_alias may be used in defining the class in
	order to provide direct access to fields using methods:

	class MyMessage < Message
		(...)
		bmp  2, "Primary Account Number (PAN)",             LLVAR_N,   :max    => 19
		(...)
		bmp_alias 2, :pan
	end

	this allows accessing fields in the following manner:

		mes = MyMessage.new 1100
		mes.pan = 474747474747
		puts mes.pan

		# Identical functionality to:
		mes[2]= 474747474747

		# or:
		mes["Primary Account Number (PAN)"]= 4747474747

	Most of the work in implementing a new set of message type lays in
	figuring out the correct fields to use defining the Message class via
	bmp.
=end

	class Message
		# The value of the MTI (Message Type Indicator) of this message.
		attr_reader :mti 

		# ISO8583 allows hex or binary bitmap, so it should be configurable
		attr_reader :use_hex_bitmap

		# Instantiate a new instance of this type of Message
		# optionally specifying an mti. 
		def initialize(mti = nil, use_hex_bitmap = false)
			# values is an internal field used to collect all the
			# bmp number | bmp name | field en/decoders | values
			# which are set in this message.
			@values = {}

			self.mti = mti if mti
			@use_hex_bitmap = use_hex_bitmap
		end

		# Set the mti of the Message using either the actual value
		# or the name of the message type that was defined using
		# Message.mti
		#
		# === Example
		#    class MyMessage < Message
		#      (...)
		#      mti 1100, "Authorization Request Acquirer Gateway"
		#    end
		#
		#    mes = MyMessage.new
		#    mes.mti = 1100 # or mes.mti = "Authorization Request Acquirer Gateway"
		def mti=(value)
			num, name = _get_mti_definition(value)
			@mti = num
		end

		# Set a field in this message, `key` is either the
		# bmp number or it's name.
		# ===Example
		#
		#    mes = BlaBlaMessage.new
		#    mes[2]=47474747                          # bmp 2 is generally the PAN
		#    mes["Primary Account Number"]=47474747   # if thats what you called the field in Message.bmp.
		def []=(key, value)
			if value.nil?
				@values.delete(key)
			else
				bmp_def              = _get_definition key
				bmp_def.value        = value
				@values[bmp_def.bmp] = bmp_def
			end
		end

		# Retrieve the decoded value of the contents of a bitmap
		# described either by the bitmap number or name.
		#
		# ===Example
		#
		#    mes = BlaBlaMessage.parse someMessageBytes
		#    mes[2] # bmp 2 is generally the PAN
		#    mes["Primary Account Number"] # if thats what you called the field in Message.bmp.
		def [](key)
			bmp_def = _get_definition key
			bmp     = @values[bmp_def.bmp]

			bmp ? bmp.value : nil
		end

		# Retrieve the byte representation of the bitmap.
		def to_b
			raise ISO8583Exception.new "no MTI set!" unless mti

			mti_enc = self.class._mti_format.encode(mti)
			mti_enc << _body.join
		end

		# Returns a nicely formatted representation of this
		# message.
		def to_s
			_mti_name = _get_mti_definition(mti)[1]
			str = "MTI:#{mti} (#{_mti_name})\n\n"

			_max = @values.values.max {|a,b| a.name.length <=> b.name.length }

			_max_name = _max.name.length

			@values.keys.sort.each{|bmp_num|
				_bmp = @values[bmp_num]
				str += ("%03d %#{_max_name}s : %s\n" % [bmp_num, _bmp.name, _bmp.value])
			}
			str
		end


		# METHODS starting with an underscore are meant for
		# internal use only ...
		#
		# MaG note:
		#  *WRONG* Ruby unlike other programming languages (aka Python)
		#  provides the necessary mechanisms to implement access control
		#  within a class, there's no need to use such thing like
		#  underscores, dunders or alikes.
		#
		#  In future versions I plan to fix this, along with the
		#  Indentation.

		# Returns an array of two byte arrays:
		# [bitmap_bytes, message_bytes]
		def _body
			unless required_fields_included?
				raise ISO8583MissingFieldException,
					"Fields `#{get_missing_fields.join(', ')}' are missing."
			end

			bitmap  = Bitmap.new
			message = ""

			@values.keys.sort.each do |bmp_num|
				bitmap.set(bmp_num)
				enc_value = @values[bmp_num].encode
				message << enc_value
			end

			if use_hex_bitmap
			      [bitmap.to_hex, message]
			else
			      [bitmap.to_bytes, message]
			end
		end

		def _get_definition(key) #:nodoc:
			b = self.class._definitions[key]

			unless b
				raise ISO8583Exception.new "no definition for field: #{key}"
			end

			b.dup
		end

		# return [mti_num, mti_value] for key being either
		# mti_num or mti_value
		def _get_mti_definition(key)
			num_hash,name_hash = self.class._mti_definitions

			if num_hash[key]
				[key, num_hash[key]]
			elsif name_hash[key]
				[name_hash[key], key]
			else
				raise ISO8583Exception.new("MTI: #{key} not allowed!")
			end
		end

		class << self

=begin
			Defines how the message type indicator is encoded into bytes. 
			===Params:
			* field    : the decoder/encoder for the MTI
			* opts     : the options to pass to this field

			=== Example
				class MyMessage < Message
					mti_format N, :length =>4
					(...)
				end

			encodes the mti of this message using the `N` field (fixed
			length, plain ASCII) and sets the fixed lengh to 4 bytes.

			See also: mti
=end
			def mti_format(field, opts)
				f = field.dup
				_handle_opts(f, opts)

				@mti_format = f
			end

=begin
			Defines the message types allowed for this type of message and
			gives them names
			
			=== Example
				class MyMessage < Message
					(...)
					mti 1100, "Authorization Request Acquirer Gateway"
				end

				mes = MyMessage.new
				mes.mti = 1100 # or mes.mti = "Authorization Request Acquirer Gateway"
			
			See Also: mti_format
=end
			def mti(value, name)
				@mtis_v ||= {}
				@mtis_n ||= {}
				@mtis_v[value] = name
				@mtis_n[name]  = value
			end

=begin
			Define a bitmap in the message
			===Params:
			* bmp   : bitmap number
			* name  : human readable form
			* field : field for encoding/decoding
			* opts  : options to pass to the field, e.g. length for fxed len fields.
			
			===Example
			
			class MyMessage < Message
				bmp 2, "PAN", LLVAR_N, :max =>19
				(...)
			end
			
			creates a class MyMessage that allows for a bitmap 2 which 
			is named "PAN" and encoded by an LLVAR_N Field. The maximum 
			length of the value is 19. This class may be used as follows:
			
				mes = MyMessage.new
				mes[2] = 474747474747 # or mes["PAN"] = 4747474747
=end
			def bmp(bmp, name, field, opts = nil)
				@defs            ||= {}
				@required_fields ||= []

				field = field.dup
				field.name = name
				field.bmp  = bmp
				_handle_opts(field, opts) if opts

				bmp_def = BMP.new bmp, name, field

				if field.required?
					@required_fields.push bmp
				end

				@defs[bmp]  = bmp_def
				@defs[name] = bmp_def
			end

=begin
			Create an alias to access bitmaps directly using a method.
			Example:
				class MyMessage < Message
					(...)
					bmp 2, "PAN", LLVAR_N

					(...)
					bmp_alias 2, :pan
				end #class

			would allow you to access the PAN like this:

				mes.pan = 1234
				puts mes.pan

			instead of:
				mes[2] = 1234
=end
			def bmp_alias(bmp, aliaz)
				define_method (aliaz) do
					bmp_ = @values[bmp]
					bmp_ ? bmp_.value : nil
				end

				define_method ("#{aliaz}=") do|value|
					self[bmp] = value
					# bmp_def = _get_definition(bmp)
					# bmp_def.value= value
					# @values[bmp] = bmp_def
				end
			end

			# Parse the bytes `str` returning a message of the defined type.
			def parse(str, use_hex_bitmap = false)
				message = self.new(nil, use_hex_bitmap)

				message.mti, rest = _mti_format.parse(str)

				bmp, rest = Bitmap.parse(rest, use_hex_bitmap)

				ary = _get_required_fields
				bmp.each do|bit|
					ary.delete bit
					bmp_def      = _definitions[bit]

					unless bmp_def
						raise ISO8583ParseException.new "The message contains fields not defined"
					end

					value, rest  = bmp_def.field.parse(rest)
					message[bit] = value
				end

				unless ary.empty?
					raise ISO8583MissingFieldException,
						"Fields `#{ary.join(', ')}' are missing."
				end


				message
			end

=begin
			access the mti definitions applicable to the Message
			
			returns a pair of hashes containing:
			
				mti_value => mti_name
			
				mti_name => mti_value
=end
			def _mti_definitions
				[@mtis_v, @mtis_n]
			end

=begin
			Access the field definitions of this class, this is a
			hash containing [bmp_number, BMP] and [bitmap_name, BMP]
			pairs.
=end
			def _definitions
				@defs
			end

			def _get_required_fields
			      @required_fields
			end

			# Returns the field definition to format the mti.
			def _mti_format
				@mti_format
			end

=begin
			METHODS starting with an underscore are meant for
			internal use only ...

			Modifies the field definitions of the fields passed
			in through the `bmp` and `mti_format` class methods.
=end
			def _handle_opts(field, opts)
				opts.each_pair do|key, value|
					key = (key.to_s+"=").to_sym

					if field.respond_to?(key)
						field.send(key, value)
					else
						warn "unknown option #{key} for #{field.name}"
					end
				end
			end
		end

		private

		def required_fields_included?
			self.class._get_required_fields.all? {|pos| @values[pos]}
		end

		def get_missing_fields
			self.class._get_required_fields.select do|pos|
				not @values[pos]
			end
		end
	end

	# Internal class used to tie together name, bitmap number, field en/decoder
	# and the value of the corresponding field
	class BMP
		attr_accessor :bmp,
		              :name,
			      :field,
			      :value

		def initialize(bmp, name, field)
			@bmp   = bmp
			@name  = name
			@field = field
		end

		def encode
			field.encode(value)
		end
	end

end

