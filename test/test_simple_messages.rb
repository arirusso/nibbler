#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class SimpleMessageTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
 
  def test_note_off
    nibbler = Nibbler.new
    msg = nibbler.parse(0x80, 0x40, 0x40)
    assert_equal(msg.class, MIDIMessage::NoteOff)
    assert_equal(msg.channel, 0)
    assert_equal(msg.note, 0x40)
    assert_equal(msg.velocity, 0x40)  
  end
  
  def test_note_on
    nibbler = Nibbler.new
    msg = nibbler.parse(0x90, 0x40, 0x40)
    assert_equal(msg.class, MIDIMessage::NoteOn)
    assert_equal(msg.channel, 0)
    assert_equal(msg.note, 0x40)
    assert_equal(msg.velocity, 0x40)  
  end  
  
end