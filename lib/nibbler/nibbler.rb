#!/usr/bin/env ruby
#
module Nibbler
 
  # this is the entry point to the app
  class Nibbler

    extend Forwardable

    attr_reader :messages,
                :processed,
                :rejected
    
    # this class holds on to all output except for the buffer because the data in the buffer
    # is the only data that's relevant between calls of Parser.process 
    def_delegators :@parser, :buffer            
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed, :processed, :clear
    def_delegator :clear_rejected, :rejected, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize(options = {}, &block)
      @timestamps = options[:timestamps] || false
      @callbacks, @processed, @rejected, @messages = [], [], [], []
      @parser = Parser.new(options)    
      @typefilter = HexCharArrayFilter.new
      block.call unless block.nil?
    end
    
    def all_messages
      @messages | @fragmented_messages
    end
    
    def buffer_s
      buffer.join
    end
    alias_method :buffer_hex, :buffer_s

    def clear_buffer
      buffer.clear
    end

    def clear_messages
      @messages.clear
    end
    
    def use_timestamps
      @messages = @messages.map do |m|
        { :messages => m, :timestamp => nil }
      end
      @timestamps = true
    end

    def parse(*a)
      a.compact!
      options = a.last.kind_of?(Hash) ? a.pop : nil      
      timestamp = options[:timestamp] if !options.nil? && !options[:timestamp].nil?
      use_timestamps if !timestamp.nil? && !@timestamps         
      queue = @typefilter.process(a)
      result = @parser.process(queue)
      record_message(result[:messages], timestamp)
      @processed += result[:processed]
      @rejected += result[:rejected]
      get_parse_output(result[:messages], options)
    end    
    
    private
        
    def record_message(msg, timestamp = nil)
      !@timestamps ? @messages += msg : @messages << { 
        :messages => msg, 
        :timestamp => timestamp 
      }     
    end
    
    def get_parse_output(messages, options = nil)
      # return type
      # 0 messages: nil
      # 1 message: the message
      # >1 message: an array of messages
      # might make sense to make this an array no matter what...iii dunnoo
      output = messages.length < 2 ? (messages.empty? ? nil : messages[0]) : messages
      output = { :messages => output, :timestamp => options[:timestamp] } if @timestamps && !options.nil?
      output      
    end
    
  end
  
end