#!/usr/bin/env ruby
#
# Parse MIDI Messages
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'forwardable'

require 'nibbler/parser'
require 'nibbler/type_filter'

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.0.1"

  # shortcut to Parser.new
  def self.new(*a)
    Parser.new(*a)
  end

end
	
