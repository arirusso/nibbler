#!/usr/bin/env ruby

require 'helper'

class MidilibFactoryTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  Parser.new(:message_lib => :midilib)
 
  def test_note_off
    factory = MidilibFactory.new
    msg = factory.note_off(0x0, 0x40, 0x40)
    assert_equal(MIDI::NoteOff, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end
  
  def test_note_on
    factory = MidilibFactory.new
    msg = factory.note_on(0x0, 0x40, 0x40)
    assert_equal(MIDI::NoteOn, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    factory = MidilibFactory.new
    msg = factory.polyphonic_aftertouch(0x1, 0x40, 0x40)
    assert_equal(MIDI::PolyPressure, msg.class)
    assert_equal(1, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.pressure)      
  end  
  
  def test_control_change
    factory = MidilibFactory.new
    msg = factory.control_change(0x2, 0x20, 0x20)
    assert_equal(MIDI::Controller, msg.class)
    assert_equal(msg.channel, 2)
    assert_equal(0x20, msg.controller)
    assert_equal(0x20, msg.value)    
  end
  
  def test_program_change
    factory = MidilibFactory.new
    msg = factory.program_change(0x3, 0x40)
    assert_equal(MIDI::ProgramChange, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x40, msg.program)  
  end
  
  def test_channel_aftertouch
    factory = MidilibFactory.new
    msg = factory.channel_aftertouch(0x3, 0x50)
    assert_equal(MIDI::ChannelPressure, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x50, msg.pressure)  
  end  
    
  def test_pitch_bend
    # to-do handle the midilib lsb/msb
    # right now the second data byte is being thrown away
    factory = MidilibFactory.new
    msg = factory.pitch_bend(0x0, 0x20, 0x00)
    assert_equal(MIDI::PitchBend, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x20, msg.value) 
  end
  
  def test_system_exclusive
    factory = MidilibFactory.new
    msg = factory.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDI::SystemExclusive, msg.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], msg.data)
  end
  
  def test_song_pointer
    factory = MidilibFactory.new
    msg = factory.system_common(0x2, 0xF0)
    assert_equal(MIDI::SongPointer, msg.class)
    assert_equal(0xF0, msg.pointer)
  end
  
  def test_song_select
    factory = MidilibFactory.new
    msg = factory.system_common(0x3, 0xA0)
    assert_equal(MIDI::SongSelect, msg.class)
    assert_equal(0xA0, msg.song)
  end
  
  def test_tune_request
    factory = MidilibFactory.new
    msg = factory.system_common(0x6)
    assert_equal(MIDI::TuneRequest, msg.class)
  end
  
  def test_clock
    factory = MidilibFactory.new
    msg = factory.system_realtime(0x8)
    assert_equal(MIDI::Clock, msg.class)
  end    

  def test_start
    factory = MidilibFactory.new
    msg = factory.system_realtime(0xA)
    assert_equal(MIDI::Start, msg.class)
  end     
  
  def test_continue
    factory = MidilibFactory.new
    msg = factory.system_realtime(0xB)
    assert_equal(MIDI::Continue, msg.class)
  end
  
  def test_stop
    factory = MidilibFactory.new
    msg = factory.system_realtime(0xC)
    assert_equal(MIDI::Stop, msg.class)
  end    
  
  def test_stop
    factory = MidilibFactory.new
    msg = factory.system_realtime(0xE)
    assert_equal(MIDI::ActiveSense, msg.class)
  end       

  def test_stop
    factory = MidilibFactory.new
    msg = factory.system_realtime(0xF)
    assert_equal(MIDI::SystemReset, msg.class)
  end       
    
end