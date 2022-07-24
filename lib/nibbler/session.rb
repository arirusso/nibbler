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

    # Parse the given integer bytes and add them to the buffer.
    # @param [Array<Integer>] bytes
    # @param [Object] timestamp A timestamp to store with the messages that result
    # @return [Array<Object>]
    def parse(*bytes, timestamp: Time.now.to_i)
      parser_report = @parser.process(*bytes)
      @events << Event.new(parser_report, timestamp)
      parser_report.messages
    end
  end
end
