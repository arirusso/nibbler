# frozen_string_literal: true

require 'midi-message'

module Nibbler
  # Construct messages with MIDIMessage in a generic way
  # http://github.com/arirusso/midi-message
  module MIDIMessage
    module_function

    def note_off(second_nibble, data_byte1, data_byte2)
      ::MIDIMessage::NoteOff.new(second_nibble, data_byte1, data_byte2)
    end

    def note_on(second_nibble, data_byte1, data_byte2)
      ::MIDIMessage::NoteOn.new(second_nibble, data_byte1, data_byte2)
    end

    def polyphonic_aftertouch(second_nibble, data_byte1, data_byte2)
      ::MIDIMessage::PolyphonicAftertouch.new(second_nibble, data_byte1, data_byte2)
    end

    def control_change(second_nibble, data_byte1, data_byte2)
      ::MIDIMessage::ControlChange.new(second_nibble, data_byte1, data_byte2)
    end

    def program_change(second_nibble, data_byte)
      ::MIDIMessage::ProgramChange.new(second_nibble, data_byte)
    end

    def channel_aftertouch(second_nibble, data_byte)
      ::MIDIMessage::ChannelAftertouch.new(second_nibble, data_byte)
    end

    def pitch_bend(second_nibble, data_byte1, data_byte2)
      ::MIDIMessage::PitchBend.new(second_nibble, data_byte1, data_byte2)
    end

    def system_exclusive(*args)
      ::MIDIMessage::SystemExclusive.new(*args)
    end

    def system_common(second_nibble, data_byte1 = nil, data_byte2 = nil)
      ::MIDIMessage::SystemCommon.new(second_nibble, data_byte1, data_byte2)
    end

    def system_realtime(second_nibble)
      ::MIDIMessage::SystemRealtime.new(second_nibble)
    end
  end
end
