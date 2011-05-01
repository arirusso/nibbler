#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class ShortMessageTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
 
  def test_note_off
    nibbler = Nibbler.new
    msg = nibbler.parse(0x80, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOff, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end
  
  def test_note_on
    nibbler = Nibbler.new
    msg = nibbler.parse(0x90, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    nibbler = Nibbler.new
    msg = nibbler.parse(0xA1, 0x40, 0x40)
    assert_equal(MIDIMessage::PolyphonicAftertouch, msg.class)
    assert_equal(1, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.value)      
  end  
  
  def test_control_change
    nibbler = Nibbler.new
    msg = nibbler.parse(0xB2, 0x20, 0x20)
    assert_equal(MIDIMessage::ControlChange, msg.class)
    assert_equal(msg.channel, 2)
    assert_equal(0x20, msg.number)
    assert_equal(0x20, msg.value)    
  end
  
  def test_program_change
    nibbler = Nibbler.new
    msg = nibbler.parse(0xC3, 0x40)
    assert_equal(MIDIMessage::ProgramChange, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x40, msg.program)  
  end
  
  def test_channel_aftertouch
    nibbler = Nibbler.new
    msg = nibbler.parse(0xD3, 0x50)
    assert_equal(MIDIMessage::ChannelAftertouch, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x50, msg.value)  
  end  
    
  def test_channel_aftertouch
    nibbler = Nibbler.new
    msg = nibbler.parse(0xE0, 0x50, 0xA0)
    assert_equal(MIDIMessage::PitchBend, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x50, msg.low)
    assert_equal(0xA0, msg.high)  
  end   
   
  def test_system_common
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1, 0x50, 0xA0)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
    assert_equal(0x50, msg.data[0])
    assert_equal(0xA0, msg.data[1])  
  end    
  
  def test_system_realtime
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF8)
    assert_equal(MIDIMessage::SystemRealtime, msg.class)
    assert_equal(8, msg.id)
  end        
   
end