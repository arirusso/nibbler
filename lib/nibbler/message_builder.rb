# frozen_string_literal: true

module Nibbler
  # Build a MIDI message from constrained raw data.
  # Enables Nibbler to use multiple MIDI message libraries
  class MessageBuilder
    attr_reader :length_in_bytes

    def self.for_system_exclusive(library)
      new(library, :system_exclusive)
    end

    def self.for_system_message(library, status)
      type_of_system_message = Message::SYSTEM.find { |type| type[:status] == status }
      new(library, type_of_system_message[:name], length_in_bytes: type_of_system_message[:bytes])
    end

    def self.for_channel_message(library, status)
      type_of_channel_message = Message::CHANNEL.find { |type| type[:status] == status }
      new(library, type_of_channel_message[:name], length_in_bytes: type_of_channel_message[:bytes])
    end

    def initialize(library, name, length_in_bytes: nil)
      @library = library
      @name = name
      @length_in_bytes = length_in_bytes
    end

    def sysex_length(bytes)
      sysex_end_index = bytes.index { |byte| byte == 0xF7 }
      sysex_end_index && sysex_end_index + 1
    end

    def sysex?
      @name == :system_exclusive
    end

    def can_build_next?(bytes, running_status: nil)
      if sysex?
        # check that there's a sysex end byte
        bytes.any? { |byte| byte == 0xF7 }
      else
        bytes_to_test = running_status ? [running_status] + bytes : bytes
        potential_data_bytes = bytes_to_test.drop(1)
        next_status_index = potential_data_bytes.index { |byte| Util.status_byte?(byte) }
        bytes_to_test = next_status_index ? potential_data_bytes.slice(0, next_status_index) : potential_data_bytes
        length_of_data = @length_in_bytes - 1
        bytes_to_test.length >= length_of_data
      end
    end

    def build(*message_data)
      @library.send(@name, *message_data)
    end
  end
end
