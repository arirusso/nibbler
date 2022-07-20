# frozen_string_literal: true

module Nibbler
  # Build a MIDI message from constrained raw data.
  # Enables Nibbler to use multiple MIDI message libraries
  class MessageBuilder
    CHANNEL_MESSAGE = [
      {
        status: 0x8,
        name: :note_off,
        nibbles: 6
      },
      {
        status: 0x9,
        name: :note_on,
        nibbles: 6
      },
      {
        status: 0xA,
        name: :polyphonic_aftertouch,
        nibbles: 6
      },
      {
        status: 0xB,
        name: :control_change,
        nibbles: 6
      },
      {
        status: 0xC,
        name: :program_change,
        nibbles: 4
      },
      {
        status: 0xD,
        name: :channel_aftertouch,
        nibbles: 4
      },
      {
        status: 0xE,
        name: :pitch_bend,
        nibbles: 6
      }
    ].freeze

    SYSTEM_MESSAGE = [
      {
        status: 0x1..0x6,
        name: :system_common,
        nibbles: 6
      },
      {
        status: 0x8..0xF,
        name: :system_realtime,
        nibbles: 2
      }
    ].freeze

    attr_reader :num_nibbles, :name

    def self.build_system_exclusive(library, *message_data)
      library.system_exclusive(*message_data)
    end

    def self.for_system_message(library, status)
      type_of_system_message = SYSTEM_MESSAGE.find { |type| type[:status].cover?(status) }
      new(library, type_of_system_message[:name], type_of_system_message[:nibbles])
    end

    def self.for_channel_message(library, status)
      type_of_channel_message = CHANNEL_MESSAGE.find { |type| type[:status] == status }
      new(library, type_of_channel_message[:name], type_of_channel_message[:nibbles])
    end

    def initialize(library, name, num_nibbles)
      @library = library
      @name = name
      @num_nibbles = num_nibbles
    end

    def build(*message_data)
      @library.send(@name, *message_data)
    end
  end
end
