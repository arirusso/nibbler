# frozen_string_literal: true

module Nibbler
  # A wrapper for the parser that has additional state properties. for example,
  # past messages, rejected bytes. These state properties aren't used by the parser.
  #
  class Session
    extend Forwardable

    attr_reader :events

    def_delegators :@parser, :buffer
    def_delegator :clear_buffer, :buffer, :clear

    Event = Struct.new(:report, :timestamp)

    # @param [Hash] options
    # @option options [Symbol] :message_lib The name of a message library module eg MIDIMessage or Midilib
    def initialize(message_lib: nil)
      @events = []
      library = MessageLibrary.adapter(message_lib)
      @parser = Parser.new(library)
    end

    def parse_string(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      integers = StringConversion.convert_strings_to_numeric_bytes(*args)
      parse(*integers)
    end
    alias parse_s parse_string

    # Parse some input
    # @param [*Object] args
    # @param [Hash] options (can be included as the last arg)
    # @option options [Time] :timestamp A timestamp to store with the messages that result
    # @return [Array<Object>, Hash]
    def parse(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      parser_report = @parser.process(*args)
      @events << Event.new(parser_report, options[:timestamp] || Time.now.to_i)
      parser_report.messages
    end
  end
end
