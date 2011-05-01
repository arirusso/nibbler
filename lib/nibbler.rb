#!/usr/bin/env ruby
#
# Parse MIDI Messages
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'midi-message'
require 'forwardable'

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.0.1"

  class Parser

    include MIDIMessage
    extend Forwardable

    attr_reader :buffer,
                :fragmented_messages,
                :messages,
                :processed_buffer
                
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed_buffer, :processed_buffer, :clear
    def_delegator :clear_fragmented_messages, :fragmented_messages, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize
      @buffer, @processed_buffer, @fragmented_messages, @messages = [], [], [], []
    end
    
    def all_messages
      @messages | @fragmented_messages
    end
    
    def buffer_hex
      @buffer.map { |d| d.to_s(16) }
    end

    def clear_buffer
      @buffer.clear
    end

    def clear_messages
      @messages.clear
    end

    def parse(*a)
      @buffer += to_bytes(a)
      parse_buffer
    end
  
    def parse_buffer
      
    end
  
    def parse_bytes(*bytes)
    end
    
    private
    
    # returns an array of bytes
    def to_bytes(*a)
      buf = []
      a.each do |thing|
        case thing
          when Array then buf += thing.map { |arr| to_bytes(arr) }.inject { |a,b| a + b }
          when String then buf += bytestr_to_bytes(thing)
          when Numeric then buf << sanitize_numeric(thing)
        end
      end
      buf.compact 
    end
    
    # converts a string of hex digits to bytes
    def bytestr_to_bytes(str)
      return [str.hex] if str.length.eql?(1)
      output = []
      until (bytestr = str.slice!(0,2)).eql?("")
        output << sanitize_numeric(bytestr.hex)
      end
      output       
    end
    
    # limit <em>byte</em> to bytes usable in MIDI ie values (0..240)
    # returns nil if the byte is outside of that range
    def sanitize_numeric(byte)
      (0..240).include?(byte) ? byte : nil
    end
  
  end

  def self.new
    Parser.new
  end

end
	
