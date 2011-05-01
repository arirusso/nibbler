#!/usr/bin/env ruby
#
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 
module Nibbler

  # this is where it all starts
  class Parser

    extend Forwardable

    attr_reader :buffer,
                :fragmented_messages,
                :messages,
                :processed_buffer
                
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed_buffer, :processed_buffer, :clear
    def_delegator :clear_fragmented_messages, :fragmented_messages, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize(options = {})
      case options[:message_lib]
        when :midilib then
          require 'midilib'
          require 'nibbler/midilib_factory'
          @message_factory = MidilibFactory.new 
        else
          require 'midi-message'
          require 'nibbler/midi-message_factory'
          @message_factory = MIDIMessageFactory.new
      end 
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
      first_nibble = bytes.first >> 4
      second_nibble = bytes.first >> 8
      case first_nibble
        when 0x8 then @message_factory.note_off(second_nibble, bytes[1], bytes[2])
        when 0x9 then @message_factory.note_on(second_nibble, bytes[1], bytes[2])
        when 0xA then @message_factory.polyphonic_aftertouch(second_nibble, bytes[1], bytes[2])
        when 0xB then @message_factory.control_change(second_nibble, bytes[1], bytes[2])
        when 0xC then @message_factory.program_change(second_nibble, bytes[1])
        when 0xD then @message_factory.channel_aftertouch(second_nibble, bytes[1])
        when 0xE then @message_factory.pitch_bend(second_nibble, bytes[1], bytes[2])
        when 0xF then case second_nibble
          when 0x0 then @message_factory.system_exclusive(*bytes)
          when 0x1..0x6 then @message_factory.system_common(second_nibble, bytes[1], bytes[2])
          when 0x8..0xF then @message_factory.system_realtime(second_nibble)
          else nil
        end
        else parse_bytes(bytes.slice(1, bytes.length-1))
      end
    end
    
    private
    
    # returns an array of bytes
    def to_bytes(*a)
      a.flatten!
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

end