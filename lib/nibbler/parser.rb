#!/usr/bin/env ruby
#
module Nibbler
 

  # this is where messages go
  class Parser
    
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
    end

    def process(nibbles)
      output = { 
        :messages => [], 
        :processed => [], 
        :remaining => nibbles,
        :rejected => [] 
      }    
      i = 0  
      while i <= (output[:remaining].length - 1)
        # iterate through nibbles until a status message is found        
        # see if there really is a message there
        processed = nibbles_to_message(output[:remaining])
        unless processed[:message].nil?
          # if it's a real message, reject previous nibbles
          output[:rejected] += output[:remaining].slice(0, i + 1)
          # and record it          
          output[:remaining] = processed[:remaining]
          output[:messages] << processed[:message]
          output[:processed] = processed[:processed]
        end
        i += 1  
      end
      output
    end
    
    def nibbles_to_message(nibbles)
      output = { 
        :message => nil, 
        :processed => [], 
        :remaining => nil 
      }
      if nibbles.length < 2
        output[:remaining] = nibbles
        return output
      end
      first = nibbles[0].hex
      second = nibbles[1].hex
      
      output[:message], output[:processed] = *case first
        when 0x8 then lookahead(6, nibbles) { |bytes| @message_factory.note_off(second, bytes[1], bytes[2]) }
        when 0x9 then lookahead(6, nibbles) { |bytes| @message_factory.note_on(second, bytes[1], bytes[2]) }
        when 0xA then lookahead(6, nibbles) { |bytes| @message_factory.polyphonic_aftertouch(second, bytes[1], bytes[2]) }
        when 0xB then lookahead(6, nibbles) { |bytes| @message_factory.control_change(second, bytes[1], bytes[2]) }
        when 0xC then lookahead(4, nibbles) { |bytes| @message_factory.program_change(second, bytes[1]) }
        when 0xD then lookahead(4, nibbles) { |bytes| @message_factory.channel_aftertouch(second, bytes[1]) }
        when 0xE then lookahead(6, nibbles) { |bytes| @message_factory.pitch_bend(second, bytes[1], bytes[2]) }
        when 0xF then case second
          when 0x0 then lookahead_sysex(nibbles) { |bytes| @message_factory.system_exclusive(*bytes) }
          when 0x1..0x6 then lookahead(6, nibbles, :recursive => true) { |bytes| @message_factory.system_common(second, bytes[1], bytes[2]) }
          when 0x8..0xF then lookahead(2, nibbles) { |bytes| @message_factory.system_realtime(second) }
        end
      end
      output[:remaining] = nibbles
      output
    end
    
    private
    
    def lookahead(num, nibbles, options = {}, &block)
      recursive = !options[:recursive].nil? && options[:recursive] 
      processed = []
      msg = nil               
      # do we have enough nibbles for num bytes?
      if nibbles.slice(0, num).length >= num
        # if so shift those nubbles off of the array and call block with them
        processed += nibbles.slice!(0, num)
        # send the nibbles to the block as bytes         
        # return the evaluated block and the remaining nibbles       
        bytes = TypeConversion.hex_chars_to_bytes(processed)
        msg = block.call(bytes)
      elsif num > 0 && recursive
        msg, processed = *lookahead(num-2, nibbles, options, &block)
      end
      [msg, processed]
    end
        
    def lookahead_sysex(nibbles, &block)
      bytes = TypeConversion.hex_chars_to_bytes(nibbles)
      ind = bytes.index(0xF7)
      processed = []
      msg = nil      
      unless ind.nil?
        msg = block.call(bytes.slice!(0, ind + 1))
        processed += nibbles.slice!(0, (ind + 1) * 2)
      end
      [msg, processed]
    end
    
  end

end