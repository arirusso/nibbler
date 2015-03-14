module Nibbler

  class Parser

    attr_reader :buffer

    # @param [Hash] options
    # @option options [Symbol] :message_lib The name of a message library module eg MIDIMessage or Midilib
    def initialize(options = {})
      @running_status = RunningStatus.new
      @buffer = []

      initialize_message_library(options[:message_lib])
    end

    # Process the given nibbles and add them to the buffer
    # @param [Array<String, Fixnum>] nibbles
    # @return [Hash]
    def process(nibbles)
      report = {
        :messages => [],
        :processed => [],
        :rejected => []
      }
      pointer = 0
      @buffer += nibbles
      # Iterate through nibbles in the buffer until a status message is found
      while pointer <= (@buffer.length - 1)
        # fragment is the piece of the buffer to look at
        fragment = get_fragment(pointer)
        # See if there really is a message there
        unless (processed = nibbles_to_message(fragment)).nil?
          # if fragment contains a real message, reject the nibbles that precede it
          report[:rejected] += @buffer.slice(0, pointer)
          # and record it
          @buffer = fragment.dup # fragment now has the remaining nibbles for next pass
          fragment = nil # Reset fragment
          pointer = 0 # Reset iterator
          report[:messages] << processed[:message]
          report[:processed] += processed[:processed]
        else
          @running_status.cancel
          pointer += 1
        end
      end
      report
    end

    # If possible, convert the given fragment to a MIDI message
    # @param [Array<String>] fragment A fragment of data eg ["9", "0", "4", "0", "5", "0"]
    # @return [Hash, nil]
    def nibbles_to_message(fragment)
      if fragment.length >= 2
        # convert the part of the fragment to start with to a numeric
        slice = fragment.slice(0..1).map(&:hex)
        compute_message(slice, fragment)
      end
    end

    private

    # Attempt to convert the given nibbles into a MIDI message
    # @param [Array<Fixnum>] nibbles
    # @return [Hash, nil]
    def compute_message(nibbles, fragment)
      case nibbles[0]
      when 0x8 then lookahead(6, fragment) { |status_2, data_bytes| @message.note_off(status_2, *data_bytes) }
      when 0x9 then lookahead(6, fragment) { |status_2, data_bytes| @message.note_on(status_2, *data_bytes) }
      when 0xA then lookahead(6, fragment) { |status_2, data_bytes| @message.polyphonic_aftertouch(status_2, *data_bytes) }
      when 0xB then lookahead(6, fragment) { |status_2, data_bytes| @message.control_change(status_2, *data_bytes) }
      when 0xC then lookahead(4, fragment) { |status_2, data_bytes| @message.program_change(status_2, *data_bytes) }
      when 0xD then lookahead(4, fragment) { |status_2, data_bytes| @message.channel_aftertouch(status_2, *data_bytes) }
      when 0xE then lookahead(6, fragment) { |status_2, data_bytes| @message.pitch_bend(status_2, *data_bytes) }
      when 0xF then
        case nibbles[1]
        when 0x0 then lookahead_sysex(fragment)
        when 0x1..0x6 then lookahead(6, fragment, :recursive => true) { |status_2, data_bytes| @message.system_common(status_2, *data_bytes) }
        when 0x8..0xF then lookahead(2, fragment) { |status_2, data_bytes| @message.system_realtime(status_2) }
        end
      else
        lookahead_using_running_status(fragment) if @running_status.possible?
      end
    end

    # Choose a MIDI message object library
    # @param [Symbol] lib The MIDI message library module eg MIDIMessage or Midilib
    # @return [Module]
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

    # Attempt to convert the fragment to a MIDI message using the given fragment and cached running status
    # @param [Array<String>] fragment A fragment of data eg ["4", "0", "5", "0"]
    # @return [Hash, nil]
    def lookahead_using_running_status(fragment)
      lookahead(@running_status[:num_nibbles], fragment, :status_nibble => @running_status[:status_nibble], &@running_status[:message_builder])
    end

    # Get the data in the buffer for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<String>]
    def get_fragment(pointer)
      @buffer[pointer, (@buffer.length - pointer)]
    end

    # If the given fragment has at least the given number of nibbles, use it to build a hash that can be used
    # to build a MIDI message
    #
    # @param [Fixnum] num_nibbles
    # @param [Array<String>] fragment
    # @param [Hash] options
    # @option options [String] :status_nibble
    # @option options [Boolean] :recursive
    # @return [Hash, nil]
    def lookahead(num_nibbles, fragment, options = {}, &message_builder)
      if fragment.size >= num_nibbles
        # if so shift those nibbles off of the array and call block with them
        nibbles = fragment.slice!(0, num_nibbles)
        status_nibble ||= options[:status_nibble] || nibbles[1]

        # send the nibbles to the block as bytes
        # return the evaluated block and the remaining nibbles
        bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)
        bytes = bytes[1..-1] if options[:status_nibble].nil?

        # record the fragment situation in case running status comes up next round
        @running_status.set(num_nibbles - 2, status_nibble, message_builder)

        result = yield(status_nibble.hex, bytes)
        {
          :message => result,
          :processed => nibbles
        }
      elsif num_nibbles > 0 && !!options[:recursive]
        lookahead(num_nibbles - 2, fragment, options, &message_builder)
      end
    end

    def lookahead_sysex(fragment)
      @running_status.cancel
      bytes = TypeConversion.hex_chars_to_numeric_bytes(fragment)
      unless (index = bytes.index(0xF7)).nil?
        message_data = bytes.slice!(0, index + 1)
        result = @message.system_exclusive(*message_data)
        {
          :message => result,
          :processed => fragment.slice!(0, (index + 1) * 2)
        }
      end
    end

    class RunningStatus

      extend Forwardable

      def_delegators :@state, :[]

      def cancel
        @state = nil
      end

      # Is there an active cached running status?
      # @return [Boolean]
      def possible?
        !@state.nil?
      end

      def set(num_nibbles, status_nibble, message_builder)
        @state = {
          :message_builder => message_builder,
          :num_nibbles => num_nibbles,
          :status_nibble => status_nibble
        }
      end

    end

  end

end
