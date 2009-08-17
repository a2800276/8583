$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "field"
require "codec"
require "fields"
require "exception"
require "bitmap"
require "message"
require "util"
