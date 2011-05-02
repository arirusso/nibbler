#!/usr/bin/env ruby
#
module Nibbler  
  
  class TypeFilter
       
    # returns an array of hex string nibbles
    def to_nibbles(*a)
      a.flatten!
      buf = []
      a.each do |thing|
        buf += case thing
          when Array then thing.map { |arr| to_nibbles(*arr) }.inject { |a,b| a + b }
          when String then hexstr_to_nibbles(thing)
          when Numeric then numbyte_to_nibbles(filter_numeric(thing))
        end
      end
      buf.compact 
    end
    
    private
    
    # converts a string of hex digits to bytes
    def hexstr_to_nibbles(str)
      str.split(//)    
    end
    
    def numbyte_to_nibbles(num)
      [((num & 0xF0) >> 4), (num & 0x0F)].map { |n| n.to_s(16) }      
    end
    
    # limit <em>num</em> to bytes usable in MIDI ie values (0..240)
    # returns nil if the byte is outside of that range
    def filter_numeric(num)
      (0x00..0xFF).include?(num) ? num : nil
    end
  
    
  end

end