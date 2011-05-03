#!/usr/bin/env ruby
#
module Nibbler  
  
  # Turns various types of input in to an array of hex digit chars
  class HexCharArrayFilter
       
    # returns an array of hex string nibbles
    def process(*a)
      a.flatten!
      buf = []
      a.each do |thing|
        buf += case thing
          when Array then thing.map { |arr| to_nibbles(*arr) }.inject { |a,b| a + b }
          when String then TypeConversion.hex_str_to_hex_chars(thing)
          when Numeric then TypeConversion.numeric_byte_to_hex_chars(filter_numeric(thing))
        end
      end
      buf.compact.map { |n| n.upcase } 
    end
    
    private
    
    # limit <em>num</em> to bytes usable in MIDI ie values (0..240)
    # returns nil if the byte is outside of that range
    def filter_numeric(num)
      (0x00..0xFF).include?(num) ? num : nil
    end
  
  end

end