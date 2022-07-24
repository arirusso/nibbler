# frozen_string_literal: true

module Nibbler
  # Parses raw data and creates midi messages. Messages, processed data and rejected data are all logged
  class Parser
    Report = Struct.new(:messages, :other, :processed)

    attr_reader :buffer

    def initialize(library)
      @library = library
      @running_status = nil
      @buffer = []
    end

    # Process the given bytes and add them to the buffer.
    # Returns a Hash report about the current state of the buffer. eg
    # with no prior input, `Parser.process(0x50, 0x90, 0x40, 0x64)` will return
    # {
    #   :messages=>[#<MIDIMessage::NoteOn:0x000000010cdc60b0
    #     @status=[9, 0],
    #     @data=[64, 100],
    #     @channel=0,
    #     @note=64,
    #     @velocity=100,
    #     @const=#<MIDIMessage::Constant::Map:0x000000010cad9780 @key="C3", @value=64>,
    #     @name="C3",
    #     @verbose_name="Note On: C3">],
    #   :processed=>[0x90, 0x40, 0x64],
    #   :rejected=>[0x50]
    # }
    #
    # @param [Array<Integer>] bytes
    # @return [Hash]
    def process(*bytes)
      report = Report.new([], [], [])
      pointer = 0
      @buffer += bytes
      pointer += process_next(pointer, report) while processable?(pointer)
      report
    end

    private

    def process_next(pointer, report)
      if Util.status_byte?(@buffer[pointer])
        handle_status_byte(pointer, report)
      elsif @running_status
        # has no status but does have running status
        handle_running_status(pointer, report)
      else
        # has no status or running status
        1
      end
    end

    def processable?(pointer)
      pointer <= @buffer.length - 1
    end

    def handle_running_status(pointer, report)
      status_nibbles = Util.numeric_byte_to_numeric_nibbles(@running_status)
      builder = message_builder_for(status_nibbles)
      if builder.can_build_next?(@buffer, running_status: @running_status)
        build_running_status_message(builder, pointer, report, status_nibble2: status_nibbles[1])
        0
      else
        # has running status, but can't build a message
        1
      end
    end

    def handle_status_byte(pointer, report)
      report.other += @buffer.slice(0, pointer) # record anything unprocessed in the buffer before this message
      status_byte = @buffer[pointer]
      status_nibbles = Util.numeric_byte_to_numeric_nibbles(status_byte)
      builder = message_builder_for(status_nibbles)
      if builder.can_build_next?(@buffer[pointer..-1])
        set_running_status(status_nibbles, status_byte)
        build_message(builder, pointer, report, status_nibble2: status_nibbles[1])
        return 0
      end

      # found status, but can't build a message
      1
    end

    def build_message(builder, pointer, report, status_nibble2:)
      num_bytes = message_length(builder)
      message_bytes = @buffer.slice!(pointer, num_bytes)
      args_for_builder = builder.sysex? ? message_bytes : [status_nibble2] + message_bytes.drop(1)
      message = builder.build(*args_for_builder)
      report.messages << message
      report.processed += message_bytes
      # pointer stays the same because the buffer has changed
    end

    def build_running_status_message(builder, pointer, report, status_nibble2:)
      expected_message_length = builder.length_in_bytes - 1
      data_bytes = @buffer.slice!(pointer, expected_message_length)
      message = builder.build(*[status_nibble2] + data_bytes)
      report.messages << message
      report.processed += data_bytes
    end

    def message_length(builder)
      builder.sysex? ? builder.sysex_length(@buffer) : builder.length_in_bytes
    end

    def message_builder_for(status_nibbles)
      case status_nibbles[0]
      when 0x8..0xE
        MessageBuilder.for_channel_message(@library, status_nibbles[0])
      when 0xF
        case status_nibbles[1]
        when 0x0 then MessageBuilder.for_system_exclusive(@library)
        else MessageBuilder.for_system_message(@library, status_nibbles[1])
        end
      end
    end

    def set_running_status(status_nibbles, status_byte)
      case status_nibbles[0]
      when 0x8..0xE then @running_status = status_byte
      when 0xF
        case status_nibbles[1]
        when 0x0..0x7 then @running_status = nil
        end
      end
    end
  end
end
