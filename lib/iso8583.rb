$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module ISO8583
  require "8583/field"
  require "8583/codec"
  require "8583/fields"
  require "8583/exception"
  require "8583/bitmap"
  require "8583/message"
  require "8583/util"
end
