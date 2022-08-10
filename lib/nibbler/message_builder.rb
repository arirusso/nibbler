# frozen_string_literal: true

module Nibbler
  # Build a MIDI message from constrained raw data.
  # Enables Nibbler to use multiple MIDI message libraries
  class MessageBuilder
    attr_reader :length_in_bytes

    # @param [Nibbler::Midilib, Nibbler::MidiMessage] library Thea message library module
    # @return [MessageBuilder]
    def self.for_system_exclusive(library)
      new(library, :system_exclusive)
    end

    # @param [Nibbler::Midilib, Nibbler::MidiMessage] library Thea message library module
    # @param [Integer] status The second nibble of a system message eg for 0xF1 this would be 0x1
    # @return [MessageBuilder]
    def self.for_system_message(library, status)
      type_of_system_message = Message::SYSTEM.find { |type| type[:status] == status }
      new(library, type_of_system_message[:name], length_in_bytes: type_of_system_message[:bytes])
    end

    # @param [Nibbler::Midilib, Nibbler::MidiMessage] library Thea message library module
    # @param [Integer] status The first nibble of a channel message eg for 0x90 this would be 0x9
    # @return [MessageBuilder]
    def self.for_channel_message(library, status)
      type_of_channel_message = Message::CHANNEL.find { |type| type[:status] == status }
      new(library, type_of_channel_message[:name], length_in_bytes: type_of_channel_message[:bytes])
    end

    # @param [Nibbler::Midilib, Nibbler::MidiMessage] library Thea message library module
    # @param [Symbol] The message name eg. :note_on
    # @param [Integer] length_in_bytes eg 3 for :note_on.  Is nil for sysex
    def initialize(library, name, length_in_bytes: nil)
      @library = library
      @name = name
      @length_in_bytes = length_in_bytes
    end

    # Given a collection of bytes beginning with 0xF0, how long is the sysex message?
    # Returns nil if there's no 0xF7 end byte found
    # @param [Array<Integer>] bytes The bytes
    # @return [Integer, nil]
    def sysex_length(bytes)
      sysex_end_index = bytes.index { |byte| byte == 0xF7 }
      sysex_end_index && sysex_end_index + 1
    end

    # Is this a sysex builder?
    # @return [Boolean]
    def sysex?
      @name == :system_exclusive
    end

    # Can this builder build a message from the given bytes?
    # @param [Array<Integer>] bytes The bytes to build a message with
    # @return [Boolean]
    def can_build_next?(bytes)
      if sysex?
        # check that there's a sysex end byte
        bytes.any? { |byte| byte == 0xF7 }
      else
        potential_data_bytes = bytes.drop(1)
        next_status_index = potential_data_bytes.index { |byte| Util.status_byte?(byte) }
        bytes_to_test = next_status_index ? potential_data_bytes.slice(0, next_status_index) : potential_data_bytes
        length_of_data = @length_in_bytes - 1
        bytes_to_test.length >= length_of_data
      end
    end

    # Builds a MIDI message from the given data
    # @param [Array<Integer>] message_data
    # @return [Object]
    def build(*message_data)
      @library.send(@name, *message_data)
    end
  end
end
