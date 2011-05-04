#!/usr/bin/env ruby
#
module Nibbler
 

  # this is where messages go
  class Parser
    
    attr_reader :buffer
    
    def initialize(options = {})
      @running_status = nil
      @buffer = []
      @iterator = 0
      
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
        :rejected => [] 
      }          
      @iterator = 0      
      @buffer += nibbles  
      while @iterator <= (@buffer.length - 1)
        # iterate through nibbles until a status message is found        
        # see if there really is a message there
        populate_current
        # current is the current piece of the buffer we're dealing with
        processed = nibbles_to_message
        unless processed[:message].nil?
          # if it's a real message, reject previous nibbles
          output[:rejected] += @buffer.slice(0, @iterator)          
          # and record it          
          @buffer = @current # current now has the remaining nibbles for next pass
          @current = nil # reset current
          @iterator = 0 # reset iterator
          output[:messages] << processed[:message]
          output[:processed] += processed[:processed]          
        else
          @running_status = nil
          @iterator += 1
        end         
      end
      output
    end
    
    def nibbles_to_message
      output = { 
        :message => nil, 
        :processed => [], 
        :remaining => nil 
      } 
      return output if @current.length < 2
      first = @current[0].hex
      second = @current[1].hex
      
      output[:message], output[:processed] = *case first
        when 0x8 then lookahead(6) { |status_2, bytes| @message_factory.note_off(status_2, bytes[1], bytes[2]) }
        when 0x9 then lookahead(6) { |status_2, bytes| @message_factory.note_on(status_2, bytes[1], bytes[2]) }
        when 0xA then lookahead(6) { |status_2, bytes| @message_factory.polyphonic_aftertouch(status_2, bytes[1], bytes[2]) }
        when 0xB then lookahead(6) { |status_2, bytes| @message_factory.control_change(status_2, bytes[1], bytes[2]) }
        when 0xC then lookahead(4) { |status_2, bytes| @message_factory.program_change(status_2, bytes[1]) }
        when 0xD then lookahead(4) { |status_2, bytes| @message_factory.channel_aftertouch(status_2, bytes[1]) }
        when 0xE then lookahead(6) { |status_2, bytes| @message_factory.pitch_bend(status_2, bytes[1], bytes[2]) }
        when 0xF then case second
          when 0x0 then lookahead_sysex { |bytes| @message_factory.system_exclusive(*bytes) }
          when 0x1..0x6 then lookahead(6, :recursive => true) { |status_2, bytes| @message_factory.system_common(status_2, bytes[1], bytes[2]) }
          when 0x8..0xF then lookahead(2) { |status_2, bytes| @message_factory.system_realtime(status_2) }
        end
        else
          use_running_status if running_status_possible?            
      end
      output
    end
    
    private
    
    def running_status_possible?
      !@running_status.nil?
    end
    
    def use_running_status
      lookahead(@running_status[:num], :status_nibble => @running_status[:status_nibble], &@running_status[:block])
    end  
    
    def populate_current
      @current = (@buffer[@iterator, (@buffer.length - @iterator)])
    end
    
    def lookahead(num, options = {}, &block)
      recursive = !options[:recursive].nil? && options[:recursive]
      status_nibble = options[:status_nibble]
      processed = []
      msg = nil             
      # do we have enough nibbles for num bytes?
      if @current.slice(0, num).length >= num

        # if so shift those nibbles off of the array and call block with them        
        processed += @current.slice!(0, num)
        status_nibble ||= processed[1]       
        # send the nibbles to the block as bytes         
        # return the evaluated block and the remaining nibbles       
        bytes = TypeConversion.hex_chars_to_numeric_bytes(processed)
        # record the current situation in case running status comes up next round
        @running_status = { 
          :block => block, 
          :num => num - 2, 
          :status_nibble => status_nibble 
        }
        msg = block.call(status_nibble.hex, bytes)
      elsif num > 0 && recursive
        msg, processed = *lookahead(num-2, options, &block)
      end
      [msg, processed]
    end
        
    def lookahead_sysex(&block)
      processed = []
      msg = nil      
      @running_status = nil
      
      bytes = TypeConversion.hex_chars_to_numeric_bytes(@current)
      ind = bytes.index(0xF7)
      unless ind.nil?
        msg = block.call(bytes.slice!(0, ind + 1))
        processed += @current.slice!(0, (ind + 1) * 2)
      end
      [msg, processed]
    end
    
    # for testing
    def buffer=(val)
      @buffer=val
    end
    
    def current
      @current
    end
    
  end

end