#!/usr/bin/env ruby
#
module Nibbler

  # factory for constructing messages with {midilib}(https://github.com/jimm/midilib)
  # midilib is copyright © 2003-2010 Jim Menard
  class MidilibFactory
    
    include MIDI
    
    def note_off(second_nibble, data_byte_1, data_byte_2)
      NoteOff.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def note_on(second_nibble, data_byte_1, data_byte_2)
      NoteOn.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def polyphonic_aftertouch(second_nibble, data_byte_1, data_byte_2)
      PolyPressure.new(second_nibble, data_byte_1, data_byte_2)
    end
      
    def control_change(second_nibble, data_byte_1, data_byte_2)
      Controller.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def program_change(second_nibble, data_byte)
      ProgramChange.new(second_nibble, data_byte)
    end
    
    def channel_aftertouch(second_nibble, data_byte)
      ChannelPressure.new(second_nibble, data_byte)
    end
    
    def pitch_bend(second_nibble, data_byte_1, data_byte_2)
      # to-do handle the midilib lsb/msb
      # right now the second data byte is being thrown away
      PitchBend.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_exclusive(*a)
      SystemExclusive.new(a)
    end
    
    def system_common(second_nibble, data_byte_1 = nil, data_byte_2 = nil)
      case second_nibble
        when 0x2 then SongPointer.new(data_byte_1) # similar issue to pitch bend here
        when 0x3 then SongSelect.new(data_byte_1)
        when 0x6 then TuneRequest.new
      end      
    end
    
    def system_realtime(second_nibble)
      case second_nibble
        when 0x8 then Clock.new
        when 0xA then Start.new
        when 0xB then Continue.new
        when 0xC then Stop.new
        when 0xE then ActiveSense.new
        when 0xF then SystemReset.new
      end      
    end  
    
  end

end