module Nibbler

  # Factory for constructing messages with midilib
  # https://github.com/jimm/midilib
  # midilib is copyright © 2003-2010 Jim Menard
  class MidilibFactory
    
    def note_off(second_nibble, data_byte_1, data_byte_2)
      MIDI::NoteOff.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def note_on(second_nibble, data_byte_1, data_byte_2)
      MIDI::NoteOn.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def polyphonic_aftertouch(second_nibble, data_byte_1, data_byte_2)
      MIDI::PolyPressure.new(second_nibble, data_byte_1, data_byte_2)
    end
      
    def control_change(second_nibble, data_byte_1, data_byte_2)
      MIDI::Controller.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def program_change(second_nibble, data_byte)
      MIDI::ProgramChange.new(second_nibble, data_byte)
    end
    
    def channel_aftertouch(second_nibble, data_byte)
      MIDI::ChannelPressure.new(second_nibble, data_byte)
    end
    
    def pitch_bend(second_nibble, data_byte_1, data_byte_2)
      # to-do handle the midilib lsb/msb
      # right now the second data byte is being thrown away
      MIDI:: PitchBend.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_exclusive(*a)
      MIDI::SystemExclusive.new(a)
    end
    
    def system_common(second_nibble, data_byte_1 = nil, data_byte_2 = nil)
      case second_nibble
        when 0x2 then MIDI::SongPointer.new(data_byte_1) # similar issue to pitch bend here
        when 0x3 then MIDI::SongSelect.new(data_byte_1)
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
