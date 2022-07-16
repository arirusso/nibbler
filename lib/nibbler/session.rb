# frozen_string_literal: true

module Nibbler
  # A wrapper for the parser that has additional state properties. for example,
  # past messages, rejected bytes. These state properties aren't used by the parser.
  #
  class Session
    extend Forwardable

    attr_reader :messages,
                :processed,
                :rejected

    def_delegators :@parser, :buffer
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed, :processed, :clear
    def_delegator :clear_rejected, :rejected, :clear
    def_delegator :clear_messages, :messages, :clear

    # @param [Hash] options
    # @option options [Symbol] :message_lib The name of a message library module eg MIDIMessage or Midilib
    # @option options [Boolean] :timestamps Whether to report timestamps
    def initialize(options = {})
      @timestamps = options[:timestamps] || false
      @callbacks = []
      @processed = []
      @rejected = []
      @messages = []
      @library = MessageLibrary.adapter(options[:message_lib])
      @parser = Parser.new(@library)
    end

    # @return [Array<Object>]
    def all_messages
      @messages | @fragmented_messages
    end

    # The buffer as a single hex string
    # @return [String]
    def buffer_s
      buffer.join
    end
    alias buffer_hex buffer_s

    # Clear the parser buffer
    def clear_buffer
      buffer.clear
    end

    # Clear the message log
    def clear_messages
      @messages.clear
    end

    # Convert messages to hashes with timestamps
    def use_timestamps
      return if @timestamps

      @messages = @messages.map do |message|
        {
          messages: message,
          timestamp: nil
        }
      end
      @timestamps = true
    end

    # Parse some input
    # @param [*Object] args
    # @param [Hash] options (can be included as the last arg)
    # @option options [Time] :timestamp A timestamp to store with the messages that result
    # @return [Array<Object>, Hash]
    def parse(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      timestamp = options[:timestamp]

      use_timestamps unless timestamp.nil?

      result = process(args)
      log(result, timestamp)
    end

    private

    # Process the input
    # @param [Array<Object>] input
    # @return [Hash]
    def process(input)
      queue = DataProcessor.process(input)
      @parser.process(queue)
    end

    # @param [Hash] parser_report
    # @param [Time] timestamp
    # @return [Array<Object>, Hash]
    def log(parser_report, timestamp)
      num = log_message(parser_report[:messages], timestamp: timestamp)
      @processed += parser_report[:processed]
      @rejected += parser_report[:rejected]
      get_output(num)
    end

    # @param [Array<Object>] messages The MIDI messages to log
    # @return [Integer] The number of MIDI messages logged
    def log_message(messages, options = {})
      if @timestamps
        messages_for_log = messages.count == 1 ? messages.first : messages
        @messages << {
          messages: messages_for_log,
          timestamp: options[:timestamp]
        }
      else
        @messages += messages
      end
      messages.count
    end

    # A report on the given number of most recent messages
    #
    # If timestamps are being used, will be a hash of messages and timestamp,
    # otherwise just the messages
    #
    # The messages type will vary depending on the number of messages that were parsed:
    # 0 messages: nil
    # 1 message: the message
    # >1 message: an array of messages
    #
    # @param [Integer] num The number of new messages to report
    # @return [Array<Object>, Hash]
    def get_output(num)
      messages = @messages.last(num)
      messages.count < 2 ? messages.first : messages
    end
  end
end
