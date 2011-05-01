#!/usr/bin/env ruby
#
# Parse MIDI Messages
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

require 'midi-message'
require 'forwardable'

#
# Parse MIDI Messages
#
module Nibbler
  
  VERSION = "0.0.1"

  class Parser

    include MIDIMessage
    extend Forwardable

    attr_reader :buffer,
                :fragmented_messages,
                :messages,
                :processed_buffer
                
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed_buffer, :processed_buffer, :clear
    def_delegator :clear_fragmented_messages, :fragmented_messages, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize
      @buffer, @processed_buffer, @fragmented_messages, @messages = [], [], [], []
    end
    
    def all_messages
      @messages | @fragmented_messages
    end
    
    def buffer_hex
      @buffer.map { |d| d.to_s(16) }
    end

    def clear_buffer
      @buffer.clear
    end

    def clear_messages
      @messages.clear
    end

    def parse(*a)
    end
  
    def parse_buffer
    end
  
    def parse_bytes(*bytes)
    end
  
  end

  def self.new
    Parser.new
  end

end
	
