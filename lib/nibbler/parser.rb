module Nibbler

  class Parser

    attr_reader :buffer

    # @param [Hash] options
    # @option options [Symbol] :message_lib
    def initialize(options = {})
      @running_status = nil
      @buffer = []
      @iterator = 0

      initialize_message_library(options[:message_lib])
    end

    # @param [Array<String, Fixnum>] nibbles
    # @return [Hash]
    def process(nibbles)
      report = { 
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
        # current is the current piece of the buffer we"re dealing with
        unless (processed = nibbles_to_message).nil?
          # if it"s a real message, reject previous nibbles
          report[:rejected] += @buffer.slice(0, @iterator)          
          # and record it          
          @buffer = @current # current now has the remaining nibbles for next pass
          @current = nil # reset current
          @iterator = 0 # reset iterator
          report[:messages] << processed[:message]
          report[:processed] += processed[:processed]          
        else
          @running_status = nil
          @iterator += 1
        end         
      end
      report
    end

    # @return [Hash, nil]
    def nibbles_to_message
      if @current.length >= 2
        nibbles = @current.slice(0..1).map(&:hex)
        compute_message(nibbles)           
      end
    end

    private

    # @param [Array<Fixnum>] nibbles
    # @return [Hash, nil]
    def compute_message(nibbles)
      case nibbles[0]
      when 0x8 then lookahead(6) { |status_2, bytes| @message.note_off(status_2, bytes[1], bytes[2]) }
      when 0x9 then lookahead(6) { |status_2, bytes| @message.note_on(status_2, bytes[1], bytes[2]) }
      when 0xA then lookahead(6) { |status_2, bytes| @message.polyphonic_aftertouch(status_2, bytes[1], bytes[2]) }
      when 0xB then lookahead(6) { |status_2, bytes| @message.control_change(status_2, bytes[1], bytes[2]) }
      when 0xC then lookahead(4) { |status_2, bytes| @message.program_change(status_2, bytes[1]) }
      when 0xD then lookahead(4) { |status_2, bytes| @message.channel_aftertouch(status_2, bytes[1]) }
      when 0xE then lookahead(6) { |status_2, bytes| @message.pitch_bend(status_2, bytes[1], bytes[2]) }
      when 0xF then 
        case nibbles[1]
        when 0x0 then lookahead_sysex { |bytes| @message.system_exclusive(*bytes) }
        when 0x1..0x6 then lookahead(6, :recursive => true) { |status_2, bytes| @message.system_common(status_2, bytes[1], bytes[2]) }
        when 0x8..0xF then lookahead(2) { |status_2, bytes| @message.system_realtime(status_2) }
        end
      else
        use_running_status if possible_running_status? 
      end
    end

    # Choose a MIDI message object library
    def initialize_message_library(lib)
      @message = case lib
      when :midilib then    
        require "nibbler/midilib"
        ::Nibbler::Midilib
      else      
        require "nibbler/midi-message"    
        ::Nibbler::MIDIMessage    
      end
    end

    def possible_running_status?
      !@running_status.nil?
    end

    def use_running_status
      lookahead(@running_status[:num], :status_nibble => @running_status[:status_nibble], &@running_status[:callback])
    end  

    def populate_current
      @current = (@buffer[@iterator, (@buffer.length - @iterator)])
    end

    def lookahead(num, options = {}, &callback)
      # do we have enough nibbles for num bytes?
      if @current.size >= num
        # if so shift those nibbles off of the array and call block with them
        nibbles = @current.slice!(0, num)
        status_nibble ||= options[:status_nibble] || nibbles[1]  

        # send the nibbles to the block as bytes         
        # return the evaluated block and the remaining nibbles       
        bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)

        # record the current situation in case running status comes up next round
        @running_status = { 
          :callback => callback, 
          :num => num - 2, 
          :status_nibble => status_nibble 
        }

        {
          :message => yield(status_nibble.hex, bytes),
          :processed => nibbles
        }
      elsif num > 0 && !!options[:recursive]
        lookahead(num - 2, options, &callback)
      end
    end

    def lookahead_sysex(&block)
      @running_status = nil

      bytes = TypeConversion.hex_chars_to_numeric_bytes(@current)
      unless (index = bytes.index(0xF7)).nil?
        {
          :message => yield(bytes.slice!(0, index + 1)),
          :processed => @current.slice!(0, (index + 1) * 2)
        }
      end
    end

  end

end
