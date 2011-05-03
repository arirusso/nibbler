#!/usr/bin/env ruby

require 'test_helper'

class ParserTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
    
  def test_lookahead
    parser = Parser.new
    num = 6
    nibbles = ["9", "0", "4", "0", "5", "0", "5", "0"]
    outp = parser.send(:lookahead, num, nibbles) { |bytes| bytes }
    assert_equal([0x90, 0x40, 0x50], outp[0])
    assert_equal(["9", "0", "4", "0", "5", "0"], outp[1])    
    assert_equal(["5", "0"], nibbles)
  end
  
  def test_lookahead_too_short
    parser = Parser.new
    num = 6
    nibbles = ["9", "0", "4"]
    outp = parser.send(:lookahead, num, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal(["9", "0", "4"], nibbles)
  end
  
  def test_lookahead_sysex
    parser = Parser.new
    nibbles = "F04110421240007F0041F750".split(//)
    outp = parser.send(:lookahead_sysex, nibbles) { |b| b }
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], outp[0])
    assert_equal("F04110421240007F0041F7".split(//), outp[1])    
    assert_equal(["5", "0"], nibbles)
  end
  
  def test_lookahead_sysex_too_short
    parser = Parser.new
    nibbles = ["9", "0", "4"]
    outp = parser.send(:lookahead_sysex, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal(["9", "0", "4"], nibbles)
  end
  
  def test_nibbles_to_message
    parser = Parser.new
    short = ['9', '0', '4', '0', '5', '0', '5', '0']
    outp = parser.send(:nibbles_to_message, short)
    assert_equal(MIDIMessage::NoteOn, outp[:message].class)
    assert_equal(['5', '0'], outp[:remaining])
    assert_equal(['9', '0', '4', '0', '5', '0'], outp[:processed])
  end
  
  def test_nibbles_to_message_sysex
    parser = Parser.new
    sysex = "F04110421240007F0041F750".split(//)
    outp = parser.send(:nibbles_to_message, sysex)
    assert_equal(MIDIMessage::SystemExclusive::Command, outp[:message].class)
    assert_equal(["5", "0"], outp[:remaining])
    assert_equal("F04110421240007F0041F7".split(//), outp[:processed])
  end  
                 
end