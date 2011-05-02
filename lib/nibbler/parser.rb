#!/usr/bin/env ruby
#
module Nibbler
 

  # this is where messages go
  class Parser

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
        when 0x8 then only_with_bytes(3, nibbles) { |b| @message_factory.note_off(second, b[1], b[2]) }
        when 0x9 then only_with_bytes(3, nibbles) { |b| @message_factory.note_on(second, b[1], b[2]) }
        when 0xA then only_with_bytes(3, nibbles) { |b| @message_factory.polyphonic_aftertouch(second, b[1], b[2]) }
        when 0xB then only_with_bytes(3, nibbles) { |b| @message_factory.control_change(second, b[1], b[2]) }
        when 0xC then only_with_bytes(2, nibbles) { |b| @message_factory.program_change(second, b[1]) }
        when 0xD then only_with_bytes(2, nibbles) { |b| @message_factory.channel_aftertouch(second, b[1]) }
        when 0xE then only_with_bytes(3, nibbles) { |b| @message_factory.pitch_bend(second, b[1], b[2]) }
        when 0xF then case second
          when 0x0 then only_with_sysex_bytes(nibbles) { |b| @message_factory.system_exclusive(*b) }
          when 0x1..0x6 then only_with_bytes(3, nibbles) { |b| @message_factory.system_common(second, b[1], b[2]) }
          when 0x8..0xF then only_with_bytes(1, nibbles) { |b| @message_factory.system_realtime(second) }
        end
      end
      output[:remaining] = nibbles
      output
    end
    
    private
    
    def only_with_bytes(num, nibbles, &block)
      processed = []
      msg = nil 
      num_nibs = num * 2              
      # do we have enough nibbles for num bytes?
      if nibbles.slice(0, num_nibs).length >= num_nibs
        # if so shift those nubbles off of the array and call block with them
        processed += nibbles.slice!(0, num_nibs)
        # send the nibbles to the block as bytes         
        # return the evaluated block and the remaining nibbles       
        bytes = nibbles_to_bytes(processed)
        msg = block.call(bytes)
      end
      [msg, processed]
    end
    
    def nibbles_to_bytes(nibbles)
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
    
    def only_with_sysex_bytes(nibbles, &block)
      bytes = nibbles_to_bytes(nibbles)
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