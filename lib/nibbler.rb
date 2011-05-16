#!/usr/bin/env ruby
#
# Parse MIDI Messages
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'forwardable'

require 'nibbler/nibbler'
require 'nibbler/parser'
require 'nibbler/type_conversion'
require 'nibbler/hex_char_array_filter'

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.0.5"

  # shortcut to Parser.new
  def self.new(*a, &block)
    Nibbler.new(*a, &block)
  end

end
	
