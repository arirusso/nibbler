module Nibbler

  class Parser

    attr_reader :buffer

    # @param [Hash] options
    # @option options [Symbol] :message_lib The name of a message library module eg MIDIMessage or Midilib
    def initialize(options = {})
      @running_status = RunningStatus.new
      @buffer = []

      MessageBuilder.use_library(options[:message_lib])
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
      when 0x8..0xE then lookahead(fragment, MessageBuilder.channel_message(nibbles[0]))
      when 0xF then
        case nibbles[1]
        when 0x0 then lookahead_sysex(fragment)
        else lookahead(fragment, MessageBuilder.system_message(nibbles[1]), :recursive => true)
        end
      else
        lookahead_using_running_status(fragment) if @running_status.possible?
      end
    end

    # Attempt to convert the fragment to a MIDI message using the given fragment and cached running status
    # @param [Array<String>] fragment A fragment of data eg ["4", "0", "5", "0"]
    # @return [Hash, nil]
    def lookahead_using_running_status(fragment)
      lookahead(fragment, @running_status[:message_builder], :offset => @running_status[:offset], :status_nibble_2 => @running_status[:status_nibble_2])
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
    # @option options [String] :status_nibble_2
    # @option options [Boolean] :recursive
    # @return [Hash, nil]
    def lookahead(fragment, message_builder, options = {})
      offset = options.fetch(:offset, 0)
      num_nibbles = message_builder.num_nibbles + offset
      if fragment.size >= num_nibbles
        # if so shift those nibbles off of the array and call block with them
        nibbles = fragment.slice!(0, num_nibbles)
        status_nibble_2 ||= options[:status_nibble_2] || nibbles[1]

        # send the nibbles to the block as bytes
        # return the evaluated block and the remaining nibbles
        bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)
        bytes = bytes[1..-1] if options[:status_nibble_2].nil?

        # record the fragment situation in case running status comes up next round
        @running_status.set(offset - 2, message_builder, status_nibble_2)

        message_args = [status_nibble_2.hex]
        message_args += bytes if num_nibbles > 2

        message = message_builder.build(*message_args)
        {
          :message => message,
          :processed => nibbles
        }
      elsif num_nibbles > 0 && !!options[:recursive]
        lookahead(fragment, message_builder, options.merge({ :offset => offset - 2 }))
      end
    end

    def lookahead_sysex(fragment)
      @running_status.cancel
      bytes = TypeConversion.hex_chars_to_numeric_bytes(fragment)
      unless (index = bytes.index(0xF7)).nil?
        message_data = bytes.slice!(0, index + 1)
        message = MessageBuilder.build_system_exclusive(*message_data)
        {
          :message => message,
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

      def set(offset, message_builder, status_nibble_2)
        @state = {
          :message_builder => message_builder,
          :offset => offset,
          :status_nibble_2 => status_nibble_2
        }
      end

    end

  end

end
