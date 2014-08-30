module Nibbler

  # Factory for constructing messages with MIDIMessage
  # http://github.com/arirusso/midi-message
  class MIDIMessageFactory
        
    def note_off(second_nibble, data_byte_1, data_byte_2)
      MIDIMessage::NoteOff.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def note_on(second_nibble, data_byte_1, data_byte_2)
      MIDIMessage::NoteOn.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def polyphonic_aftertouch(second_nibble, data_byte_1, data_byte_2)
      MIDIMessage::PolyphonicAftertouch.new(second_nibble, data_byte_1, data_byte_2)
    end
      
    def control_change(second_nibble, data_byte_1, data_byte_2)
      MIDIMessage::ControlChange.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def program_change(second_nibble, data_byte)
      MIDIMessage::ProgramChange.new(second_nibble, data_byte)
    end
    
    def channel_aftertouch(second_nibble, data_byte)
      MIDIMessage::ChannelAftertouch.new(second_nibble, data_byte)
    end
    
    def pitch_bend(second_nibble, data_byte_1, data_byte_2)
      MIDIMessage::PitchBend.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_exclusive(*a)
      MIDIMessage::SystemExclusive.new(*a)
    end
    
    def system_common(second_nibble, data_byte_1 = nil, data_byte_2 = nil)
      MIDIMessage::SystemCommon.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_realtime(second_nibble)
      MIDIMessage::SystemRealtime.new(second_nibble)
    end

  end

end
