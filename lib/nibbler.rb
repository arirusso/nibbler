#
# Parse MIDI Messages
# (c)2011-2014 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"

# classes
require "nibbler/nibbler"
require "nibbler/parser"
require "nibbler/hex_char_array_filter"

# helpers
require "nibbler/type_conversion"

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.1.1"

  # Shortcut to Parser.new
  def self.new(*a, &block)
    Nibbler.new(*a, &block)
  end

end
	
