#!/usr/bin/env ruby

require 'test_helper'

class ShortMessageMidilibTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
 
  def test_note_off
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0x80, 0x40, 0x40)
    assert_equal(MIDI::NoteOff, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end
  
  def test_note_on
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0x90, 0x40, 0x40)
    assert_equal(MIDI::NoteOn, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0xA1, 0x40, 0x40)
    assert_equal(MIDI::PolyPressure, msg.class)
    assert_equal(1, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.pressure)      
  end  
  
  def test_control_change
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0xB2, 0x20, 0x20)
    assert_equal(MIDI::Controller, msg.class)
    assert_equal(msg.channel, 2)
    assert_equal(0x20, msg.controller)
    assert_equal(0x20, msg.value)    
  end
  
  def test_program_change
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0xC3, 0x40)
    assert_equal(MIDI::ProgramChange, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x40, msg.program)  
  end
  
  def test_channel_aftertouch
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0xD3, 0x50)
    assert_equal(MIDI::ChannelPressure, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x50, msg.pressure)  
  end  
    
  def test_pitch_bend
    # to-do handle the midilib lsb/msb
    # right now the second data byte is being thrown away
    nibbler = Nibbler.new(:message_lib => :midilib)
    msg = nibbler.parse(0xE0, 0x20, 0x00)
    assert_equal(MIDI::PitchBend, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x20, msg.value) 
  end   
   
end