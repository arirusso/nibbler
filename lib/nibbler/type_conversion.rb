#!/usr/bin/env ruby
#
module Nibbler
 
  # this is a helper for converting nibbles and bytes
  module TypeConversion
    
    def self.hex_chars_to_bytes(nibbles)
      nibbles = nibbles.dup
      # get rid of last nibble if there's an odd number
      # it will be processed later anyway
      nibbles.slice!(nibbles.length-2, 1) if nibbles.length.odd?
      bytes = []
      while !(nibs = nibbles.slice!(0,2)).empty?
        byte = (nibs[0].hex << 4) + nibs[1].hex
        bytes << byte
      end
      bytes
    end

    
  end
  
end