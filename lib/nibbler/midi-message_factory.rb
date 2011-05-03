#!/usr/bin/env ruby
#
module Nibbler

  # factory for constructing messages with {midi-message}(http://github.com/arirusso/midi-message)
  class MIDIMessageFactory
    
    include MIDIMessage
    
    def note_off(second_nibble, data_byte_1, data_byte_2)
      NoteOff.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def note_on(second_nibble, data_byte_1, data_byte_2)
      NoteOn.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def polyphonic_aftertouch(second_nibble, data_byte_1, data_byte_2)
      PolyphonicAftertouch.new(second_nibble, data_byte_1, data_byte_2)
    end
      
    def control_change(second_nibble, data_byte_1, data_byte_2)
      ControlChange.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def program_change(second_nibble, data_byte)
      ProgramChange.new(second_nibble, data_byte)
    end
    
    def channel_aftertouch(second_nibble, data_byte)
      ChannelAftertouch.new(second_nibble, data_byte)
    end
    
    def pitch_bend(second_nibble, data_byte_1, data_byte_2)
      PitchBend.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_exclusive(*a)
      SystemExclusive.new(*a)
    end
    
    def system_common(second_nibble, data_byte_1 = nil, data_byte_2 = nil)
      SystemCommon.new(second_nibble, data_byte_1, data_byte_2)
    end
    
    def system_realtime(second_nibble)
      SystemRealtime.new(second_nibble)
    end
    
        
  
  end

end