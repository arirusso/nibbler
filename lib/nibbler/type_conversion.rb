#!/usr/bin/env ruby
#
module Nibbler
 
  # this is a helper for converting nibbles and bytes
  module TypeConversion
    
    def self.hex_chars_to_numeric_bytes(nibbles)
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
    
    # converts a string of hex digits to bytes
    def self.hex_str_to_hex_chars(str)
      str.split(//)    
    end
    
    def self.numeric_byte_to_hex_chars(num)
      [((num & 0xF0) >> 4), (num & 0x0F)].map { |n| n.to_s(16) }      
    end

    
  end
  
end