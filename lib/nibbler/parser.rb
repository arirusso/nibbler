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
        processed = nibbles_to_message
        unless processed[:message].nil?
          # if it's a real message, reject previous nibbles
          output[:rejected] += @buffer.slice(0, @iterator)
          
          # and record it          
          @buffer = @current #processed[:remaining]
          @current = nil
          output[:messages] << processed[:message]
          output[:processed] = processed[:processed]          
        end
        @iterator += 1  
      end
      output
    end
    
    def nibbles_to_message
      output = { 
        :message => nil, 
        :processed => [], 
        :remaining => nil 
      } 
      if @current.length < 2
        #output[:remaining] = @current
        return output
      end
      first = @current[0].hex
      second = @current[1].hex
      
      output[:message], output[:processed] = *case first
        when 0x8 then lookahead(6) { |bytes| @message_factory.note_off(second, bytes[1], bytes[2]) }
        when 0x9 then lookahead(6) { |bytes| @message_factory.note_on(second, bytes[1], bytes[2]) }
        when 0xA then lookahead(6) { |bytes| @message_factory.polyphonic_aftertouch(second, bytes[1], bytes[2]) }
        when 0xB then lookahead(6) { |bytes| @message_factory.control_change(second, bytes[1], bytes[2]) }
        when 0xC then lookahead(4) { |bytes| @message_factory.program_change(second, bytes[1]) }
        when 0xD then lookahead(4) { |bytes| @message_factory.channel_aftertouch(second, bytes[1]) }
        when 0xE then lookahead(6) { |bytes| @message_factory.pitch_bend(second, bytes[1], bytes[2]) }
        when 0xF then case second
          when 0x0 then lookahead_sysex { |bytes| @message_factory.system_exclusive(*bytes) }
          when 0x1..0x6 then lookahead(6, :recursive => true) { |bytes| @message_factory.system_common(second, bytes[1], bytes[2]) }
          when 0x8..0xF then lookahead(2) { |bytes| @message_factory.system_realtime(second) }
        end
      end
      #output[:remaining] = @current
      #@current = nil
      output
    end
    
    private
    
    def populate_current
      @current = (@buffer[@iterator, (@buffer.length - @iterator)])
    end
    
    def lookahead(num, options = {}, &block)
      recursive = !options[:recursive].nil? && options[:recursive]
      processed = []
      msg = nil               
 
      # do we have enough nibbles for num bytes?
      if @current.slice(0, num).length >= num
        # if so shift those nubbles off of the array and call block with them
        processed += @current.slice!(0, num)
        # send the nibbles to the block as bytes         
        # return the evaluated block and the remaining nibbles       
        bytes = TypeConversion.hex_chars_to_numeric_bytes(processed)
        msg = block.call(bytes)
      elsif num > 0 && recursive
        msg, processed = *lookahead(num-2, options, &block)
      end
      [msg, processed]
    end
        
    def lookahead_sysex(&block)
      processed = []
      msg = nil      

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