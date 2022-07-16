# frozen_string_literal: true

module Nibbler
  # Parses raw data and creates midi messages. Messages, processed data and rejected data are all logged
  class Parser
    attr_reader :buffer

    def initialize(library)
      @library = library
      @running_status = RunningStatus.new
      @buffer = []
    end

    # Process the given nibbles and add them to the buffer
    # @param [Array<String, Integer>] nibbles
    # @return [Hash]
    def process(nibbles)
      report = { messages: [], processed: [], rejected: [] }
      pointer = 0
      @buffer += nibbles
      # Iterate through nibbles in the buffer until a status message is found
      while pointer <= (@buffer.length - 1)
        # fragment is the data from the buffer to look at during the current iteration
        fragment = get_fragment_from_buffer(pointer)
        pointer = process_fragment(fragment, pointer, report) ? 0 : pointer + 1
      end
      report
    end

    private

    def process_fragment(fragment, pointer, report)
      # See if there really is a message there
      if (processed = nibbles_to_message(fragment))
        # if fragment contains a real message, reject the loose nibbles that precede it
        report[:rejected] += @buffer.slice(0, pointer)
        # and record it
        @buffer = fragment.dup # fragment now has the remaining nibbles for next pass
        report[:messages] << processed[:message]
        report[:processed] += processed[:processed]
        report
      else
        @running_status.cancel
        nil
      end
    end

    # If possible, convert the given fragment to a MIDI message
    # @param [Array<String>] fragment A fragment of data eg ["9", "0", "4", "0", "5", "0"]
    # @return [Hash, nil]
    def nibbles_to_message(fragment)
      return unless fragment.length >= 2

      # convert the part of the fragment to start with to a numeric
      slice = fragment.slice(0..1).map(&:hex)
      compute_message(slice, fragment)
    end

    # Attempt to convert the given nibbles into a MIDI message
    # @param [Array<Integer>] nibbles
    # @return [Hash, nil]
    def compute_message(nibbles, fragment)
      case nibbles[0]
      when 0x8..0xE then lookahead(fragment, MessageBuilder.for_channel_message(@library, nibbles[0]))
      when 0xF
        case nibbles[1]
        when 0x0 then lookahead_for_sysex(fragment)
        else lookahead(fragment, MessageBuilder.for_system_message(@library, nibbles[1]), is_recursive: true)
        end
      else
        lookahead_using_running_status(fragment) if @running_status.possible?
      end
    end

    # Attempt to convert the fragment to a MIDI message using the given fragment and cached running status
    # @param [Array<String>] fragment A fragment of data eg ["4", "0", "5", "0"]
    # @return [Hash, nil]
    def lookahead_using_running_status(fragment)
      lookahead(fragment, @running_status[:message_builder], offset: @running_status[:offset],
                                                             status_nibble2: @running_status[:status_nibble2])
    end

    # Get the data in the buffer for the given pointer
    # @param [Integer] pointer
    # @return [Array<String>]
    def get_fragment_from_buffer(pointer)
      @buffer[pointer, (@buffer.length - pointer)]
    end

    # If the given fragment has at least the given number of nibbles, use it to build a hash that can be used
    # to build a MIDI message
    #
    # @param [Integer] num_nibbles
    # @param [Array<String>] fragment
    # @param [Hash] options
    # @option options [Integer] :offset
    # @option options [String] :status_nibble_2
    # @option options [Boolean] :is_recursive
    # @return [Hash, nil]
    def lookahead(fragment, message_builder, status_nibble2: nil, offset: 0, is_recursive: false)
      num_nibbles = message_builder.num_nibbles + offset
      if fragment.size >= num_nibbles
        # if so shift those nibbles off of the array and call block with them
        nibbles = fragment.slice!(0, num_nibbles)

        # send the nibbles to the block as bytes
        # return the evaluated block and the remaining nibbles
        bytes = to_numeric_bytes(nibbles, status_nibble2: status_nibble2)

        # record the fragment situation in case running status comes up next round
        @running_status.set(offset - 2, message_builder, status_nibble2 || nibbles[1])

        message = build_message(bytes, message_builder, num_nibbles, status_nibble2 || nibbles[1])
        { message: message, processed: nibbles }
      elsif num_nibbles.positive? && is_recursive
        lookahead(fragment, message_builder, offset: offset - 2, is_recursive: true)
      end
    end

    def build_message(bytes, message_builder, num_nibbles, status_nibble2)
      message_args = [status_nibble2.hex]
      message_args += bytes if num_nibbles > 2

      message_builder.build(*message_args)
    end

    def to_numeric_bytes(nibbles, status_nibble2:)
      bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)
      bytes = bytes[1..-1] if status_nibble2.nil?
      bytes
    end

    def lookahead_for_sysex(fragment)
      @running_status.cancel
      bytes = TypeConversion.hex_chars_to_numeric_bytes(fragment)
      return if (index = bytes.index(0xF7)).nil?

      message_data = bytes.slice!(0, index + 1)
      message = MessageBuilder.build_system_exclusive(@library, *message_data)
      {
        message: message,
        processed: fragment.slice!(0, (index + 1) * 2)
      }
    end

    # Running status allows the transmission of shorthand MIDI messages when a string of messages
    # has the same status byte.  eg note on messages
    # [90 40 50] [90 30 50] [90 20 50]
    # can be trasmitted as
    # [90 40 50] [30 50] [20 50]
    # Note that not all devices support this
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

      def set(offset, message_builder, status_nibble2)
        @state = {
          message_builder: message_builder,
          offset: offset,
          status_nibble2: status_nibble2
        }
      end
    end
  end
end
