require "helper"

class MidilibTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  Parser.new(:message_lib => :midilib)
 
  def test_note_off
    lib = Midilib
    message = lib.note_off(0x0, 0x40, 0x40)
    assert_equal(MIDI::NoteOff, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)  
  end
  
  def test_note_on
    lib = Midilib
    message = lib.note_on(0x0, 0x40, 0x40)
    assert_equal(MIDI::NoteOn, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    lib = Midilib
    message = lib.polyphonic_aftertouch(0x1, 0x40, 0x40)
    assert_equal(MIDI::PolyPressure, message.class)
    assert_equal(1, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.pressure)      
  end  
  
  def test_control_change
    lib = Midilib
    message = lib.control_change(0x2, 0x20, 0x20)
    assert_equal(MIDI::Controller, message.class)
    assert_equal(message.channel, 2)
    assert_equal(0x20, message.controller)
    assert_equal(0x20, message.value)    
  end
  
  def test_program_change
    lib = Midilib
    message = lib.program_change(0x3, 0x40)
    assert_equal(MIDI::ProgramChange, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x40, message.program)  
  end
  
  def test_channel_aftertouch
    lib = Midilib
    message = lib.channel_aftertouch(0x3, 0x50)
    assert_equal(MIDI::ChannelPressure, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x50, message.pressure)  
  end  
    
  def test_pitch_bend
    # to-do handle the midilib lsb/msb
    # right now the second data byte is being thrown away
    lib = Midilib
    message = lib.pitch_bend(0x0, 0x20, 0x00)
    assert_equal(MIDI::PitchBend, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x20, message.value) 
  end
  
  def test_system_exclusive
    lib = Midilib
    message = lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDI::SystemExclusive, message.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], message.data)
  end
  
  def test_song_pointer
    lib = Midilib
    message = lib.system_common(0x2, 0xF0)
    assert_equal(MIDI::SongPointer, message.class)
    assert_equal(0xF0, message.pointer)
  end
  
  def test_song_select
    lib = Midilib
    message = lib.system_common(0x3, 0xA0)
    assert_equal(MIDI::SongSelect, message.class)
    assert_equal(0xA0, message.song)
  end
  
  def test_tune_request
    lib = Midilib
    message = lib.system_common(0x6)
    assert_equal(MIDI::TuneRequest, message.class)
  end
  
  def test_clock
    lib = Midilib
    message = lib.system_realtime(0x8)
    assert_equal(MIDI::Clock, message.class)
  end    

  def test_start
    lib = Midilib
    message = lib.system_realtime(0xA)
    assert_equal(MIDI::Start, message.class)
  end     
  
  def test_continue
    lib = Midilib
    message = lib.system_realtime(0xB)
    assert_equal(MIDI::Continue, message.class)
  end
  
  def test_stop
    lib = Midilib
    message = lib.system_realtime(0xC)
    assert_equal(MIDI::Stop, message.class)
  end    
  
  def test_sense
    lib = Midilib
    message = lib.system_realtime(0xE)
    assert_equal(MIDI::ActiveSense, message.class)
  end       

  def test_reset
    lib = Midilib
    message = lib.system_realtime(0xF)
    assert_equal(MIDI::SystemReset, message.class)
  end       
    
end
