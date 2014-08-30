#
# Parse MIDI Messages
# (c)2011-2014 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"

# modules
require "nibbler/hex_processor"
require "nibbler/type_conversion"

# classes
require "nibbler/parser"
require "nibbler/session"

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.1.1"

  # Shortcut to a new parser session
  def self.new(*a, &block)
    Session.new(*a, &block)
  end

end
	
