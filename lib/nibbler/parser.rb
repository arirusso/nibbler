#!/usr/bin/env ruby
#
module Nibbler

  # this is where messages go
  class Parser

    extend Forwardable

    attr_reader :buffer,
                :messages,
                :processed_buffer,
                :rejected_bytes
                
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed_buffer, :processed_buffer, :clear
    def_delegator :clear_rejected_bytes, :rejected_bytes, :clear
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
      @buffer, @processed_buffer, @rejected_bytes, @messages = [], [], [], []
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
      parsed = parse_bytes(*@buffer)
      @messages += parsed[:messages]
      @processed_buffer += parsed[:processed_bytes]
      @rejected_bytes = parsed[:rejected_bytes]
      @buffer = parsed[:remaining_bytes]
      # output
      # 0 messages: nil
      # 1 message: the message
      # >1 message: an array of messages
      # might make sense to make this an array no matter what...
      parsed[:messages].length < 2 ? (parsed[:messages].empty? ? nil : parsed[:messages][0]) : parsed[:messages]
    end
  
    def parse_bytes(*bytes)
      output = { 
        :messages => [], 
        :processed_bytes => [], 
        :remaining_bytes => bytes,
        :rejected_bytes => [] 
      }    
      i = 0  
      while i <= (output[:remaining_bytes].length - 1)
        # iterate through bytes until a status message is found        
        # see if there really is a message there
        processed = bytes_to_message(output[:remaining_bytes])     
        unless processed[:message].nil?
          # if it's a real message, reject previous bytes
          output[:rejected_bytes] += output[:remaining_bytes].slice(0, i + 1)
          # and record it          
          output[:remaining_bytes] = processed[:remaining]
          output[:messages] << processed[:message]
          output[:processed_bytes] = processed[:processed]
        end
        i += 1  
      end
      output
    end
    
    def bytes_to_message(bytes)
      output = { 
        :message => nil, 
        :processed => [], 
        :remaining => nil 
      }
      first = bytes[0]
      first_nibble = first >> 4
      second_nibble = first >> 8
      output[:message], output[:processed] = *case first_nibble
        when 0x8 then only_with_bytes(3, bytes) { |b| @message_factory.note_off(second_nibble, b[1], b[2]) }
        when 0x9 then only_with_bytes(3, bytes) { |b| @message_factory.note_on(second_nibble, b[1], b[2]) }
        when 0xA then only_with_bytes(3, bytes) { |b| @message_factory.polyphonic_aftertouch(second_nibble, b[1], b[2]) }
        when 0xB then only_with_bytes(3, bytes) { |b| @message_factory.control_change(second_nibble, b[1], b[2]) }
        when 0xC then only_with_bytes(2, bytes) { |b| @message_factory.program_change(second_nibble, b[1]) }
        when 0xD then only_with_bytes(2, bytes) { |b| @message_factory.channel_aftertouch(second_nibble, b[1]) }
        when 0xE then only_with_bytes(3, bytes) { |b| @message_factory.pitch_bend(second_nibble, b[1], b[2]) }
        when 0xF then case second_nibble
          when 0x0 then only_with_sysex_bytes(bytes) { |b| @message_factory.system_exclusive(*b) }
          when 0x1..0x6 then only_with_bytes(3, bytes) { |b| @message_factory.system_common(second_nibble, b[1], b[2]) }
          when 0x8..0xF then @message_factory.system_realtime(second_nibble)
        end
      end
      output[:remaining] = bytes
      output
    end
    
    private
    
    def only_with_bytes(num, bytes, &block)              
      if bytes.slice(0, num).length >= num
        msg = bytes.slice!(0, num)
        [block.call(msg), msg]
      end  
    end
    
    def only_with_sysex_bytes(bytes, &block)
      ind = bytes.index(0xF7)      
      unless ind.nil?
        msg = block.call(bytes.slice!(0, ind + 1))
        [msg, bytes]
      end 
    end
    
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