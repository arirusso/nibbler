# frozen_string_literal: true

module Nibbler
  # A wrapper for the parser that has additional state properties. for example,
  # past messages, rejected bytes. These state properties aren't used by the parser.
  #
  class Session
    extend Forwardable

    attr_reader :events

    def_delegators :@parser, :buffer

    Event = Struct.new(:report, :timestamp)

    # @param [Hash] options
    # @param [Symbol] message_lib The name of a message library module eg :midilib or :midi_message
    def initialize(message_lib: nil)
      @events = []
      library = MessageLibrary.adapter(message_lib)
      @parser = Parser.new(library)
    end

    # Clear the parser buffer
    # @return [Array<Integer>]
    def clear
      @parser.buffer.clear
    end

    # Parse some string input.  Can be single or multiple bytes
    # eg single '40'
    # eg multiple '4050'
    # @param [Array<Integer>] bytes
    # @param [Object] timestamp A timestamp to store with the messages that result
    # @return [Array<Object>]
    def parse_string(*args, timestamp: Time.now.to_i)
      integers = Util::Conversion.strings_to_numeric_bytes(*args)
      parse(*integers, timestamp: timestamp)
    end
    alias parse_s parse_string

    # Parse some string input.  Can be single or multiple bytes. Returns an event struct
    # eg single '40'
    # eg multiple '4050'
    # @param [Array<Integer>] bytes
    # @param [Object] timestamp A timestamp to store with the messages that result
    # @return [Event]
    def parse_string_to_event(*args, timestamp: Time.now.to_i)
      integers = Util::Conversion.strings_to_numeric_bytes(*args)
      parse_to_event(*integers, timestamp: timestamp)
    end

    # Parse the given integer bytes and add them to the buffer.
    # @param [Array<Integer>] bytes
    # @param [Object] timestamp A timestamp to store with the messages that result
    # @return [Array<Object>]
    def parse(*bytes, timestamp: Time.now.to_i)
      parse_to_event(*bytes, timestamp: timestamp).report.messages
    end

    # Parse the given integer bytes, add them to the buffer and return an event struct
    # @param [Array<Integer>] bytes
    # @param [Object] timestamp A timestamp to store with the messages that result
    # @return [Event]
    def parse_to_event(*bytes, timestamp: Time.now.to_i)
      parser_report = @parser.process(*bytes)
      event = Event.new(parser_report, timestamp)
      @events << event
      event
    end
  end
end
