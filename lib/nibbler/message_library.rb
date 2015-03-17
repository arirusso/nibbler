module Nibbler

  class MessageLibrary

    # MIDI message object library adapter
    # @param [Symbol] lib The MIDI message library module eg MIDIMessage or Midilib
    # @return [Module]
    def self.adapter(lib = nil)
      case lib
      when :midilib then
        require "nibbler/midilib"
        ::Nibbler::Midilib
      else
        require "nibbler/midi-message"
        ::Nibbler::MIDIMessage
      end
    end

  end

end
