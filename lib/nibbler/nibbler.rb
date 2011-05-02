#!/usr/bin/env ruby
#
module Nibbler
 
  # this is the entry point to the app
  class Nibbler

    extend Forwardable

    attr_reader :buffer,
                :messages,
                :processed,
                :rejected
                
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed, :processed, :clear
    def_delegator :clear_rejected, :rejected, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize(options = {})
      @buffer, @processed, @rejected, @messages = [], [], [], []
      @parser = Parser.new(options)    
      @typefilter = HexCharArrayFilter.new
    end
    
    def all_messages
      @messages | @fragmented_messages
    end
    
    def buffer_hex
      @buffer.join
    end

    def clear_buffer
      @buffer.clear
    end

    def clear_messages
      @messages.clear
    end

    def parse(*a)
      @buffer += @typefilter.process(a)
      result = @parser.process(@buffer)
      @messages += result[:messages]
      @processed += result[:processed]
      @rejected = result[:rejected]
      @buffer = result[:remaining]
      # return type
      # 0 messages: nil
      # 1 message: the message
      # >1 message: an array of messages
      # might make sense to make this an array no matter what...
      if result[:messages].length < 2 
        (result[:messages].empty? ? nil : result[:messages][0])
      else 
        result[:messages]
      end
    end
    
  end
  
end