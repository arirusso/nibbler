module Nibbler

  class MessageBuilder

    attr_reader :num_nibbles, :type

    class << self
      attr_reader :library
    end

    # Choose a MIDI message object library
    # @param [Symbol] lib The MIDI message library module eg MIDIMessage or Midilib
    # @return [Module]
    def self.use_library(lib)
      @library = case lib
      when :midilib then
        require "nibbler/midilib"
        ::Nibbler::Midilib
      else
        require "nibbler/midi-message"
        ::Nibbler::MIDIMessage
      end
    end

    def self.system_message(status)
      SYSTEM_MESSAGE.select { |k,v| k.cover?(status) }.values.first
    end

    def self.channel_message(status)
      CHANNEL_MESSAGE[status]
    end

    def initialize(type, num_nibbles)
      @type = type
      @num_nibbles = num_nibbles
    end

    def build(*args)
      self.class.library.send(@type, *args)
    end

    def self.build_system_exclusive(*args)
      @library.system_exclusive(*args)
    end

    CHANNEL_MESSAGE = {
      0x8 => MessageBuilder.new(:note_off, 6),
      0x9 => MessageBuilder.new(:note_on, 6),
      0xA => MessageBuilder.new(:polyphonic_aftertouch, 6),
      0xB => MessageBuilder.new(:control_change, 6),
      0xC => MessageBuilder.new(:program_change, 4),
      0xD => MessageBuilder.new(:channel_aftertouch, 4),
      0xE => MessageBuilder.new(:pitch_bend, 6)
    }.freeze

    SYSTEM_MESSAGE = {
      0x1..0x6 => MessageBuilder.new(:system_common, 6),
      0x8..0xF => MessageBuilder.new(:system_realtime, 2)
    }.freeze

  end

end
