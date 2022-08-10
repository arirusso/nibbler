# frozen_string_literal: true

module Nibbler
  # Abstraction to represent which Ruby MIDI message library is being used
  class MessageLibrary
    # MIDI message object library adapter
    # @param [Symbol] lib The name of a message library module eg :midilib or :midi_message
    # @return [Module]
    def self.adapter(lib = nil)
      case lib
      when :midilib
        require 'nibbler/midilib'
        ::Nibbler::Midilib
      else
        require 'nibbler/midi-message'
        ::Nibbler::MIDIMessage
      end
    end
  end
end
