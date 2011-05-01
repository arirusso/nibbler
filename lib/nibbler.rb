#!/usr/bin/env ruby
#
# Parse MIDI Messages
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

#require 'midi-message'
require 'forwardable'

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
	
