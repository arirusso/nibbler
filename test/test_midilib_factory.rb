#!/usr/bin/env ruby

require 'test_helper'



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
   
end