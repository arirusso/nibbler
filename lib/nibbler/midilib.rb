# frozen_string_literal: true

require 'midilib'

module Nibbler
  # Construct messages with midilib in a generic way
  # https://github.com/jimm/midilib
  # midilib is copyright © 2003-2010 Jim Menard
  module Midilib
    module_function

    def note_off(second_nibble, data_byte1, data_byte2)
      MIDI::NoteOff.new(second_nibble, data_byte1, data_byte2)
    end

    def note_on(second_nibble, data_byte1, data_byte2)
      MIDI::NoteOn.new(second_nibble, data_byte1, data_byte2)
    end

    def polyphonic_aftertouch(second_nibble, data_byte1, data_byte2)
      MIDI::PolyPressure.new(second_nibble, data_byte1, data_byte2)
    end

    def control_change(second_nibble, data_byte1, data_byte2)
      MIDI::Controller.new(second_nibble, data_byte1, data_byte2)
    end

    def program_change(second_nibble, data_byte)
      MIDI::ProgramChange.new(second_nibble, data_byte)
    end

    def channel_aftertouch(second_nibble, data_byte)
      MIDI::ChannelPressure.new(second_nibble, data_byte)
    end

    def pitch_bend(second_nibble, data_byte1, data_byte2)
      MIDI::PitchBend.new(second_nibble, data_byte2 * 128 + data_byte1)
    end

    def system_exclusive(*args)
      MIDI::SystemExclusive.new(args)
    end

    def system_common(second_nibble, data_byte1 = nil, _data_byte2 = nil)
      case second_nibble
      when 0x2 then MIDI::SongPointer.new(data_byte1) # similar issue to pitch bend here
      when 0x3 then MIDI::SongSelect.new(data_byte1)
      when 0x6 then MIDI::TuneRequest.new
      end
    end

    def system_realtime(second_nibble)
      case second_nibble
      when 0x8 then MIDI::Clock.new
      when 0xA then MIDI::Start.new
      when 0xB then MIDI::Continue.new
      when 0xC then MIDI::Stop.new
      when 0xE then MIDI::ActiveSense.new
      when 0xF then MIDI::SystemReset.new
      end
    end
  end
end
