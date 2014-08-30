require "helper"

class ParserRejectedTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_leading_chars
    nibbler = Nibbler.new
    msg = nibbler.parse("0", "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)        
    assert_equal(["0"], nibbler.rejected)   
  end

  def test_2_leading_chars
    nibbler = Nibbler.new
    msg = nibbler.parse("1", "0", "9", "04", "040")
    assert_equal(["1", "0"], nibbler.rejected)
  end
    
  def test_leading_string
    nibbler = Nibbler.new
    msg = nibbler.parse("10", "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(["1", "0"], nibbler.rejected)
  end
  
  def test_long_leading_string
    nibbler = Nibbler.new
    msg = nibbler.parse("000001000010", "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal("000001000010".split(//), nibbler.rejected)
  end
  
  def test_long_leading_string_overlap
    nibbler = Nibbler.new
    msg = nibbler.parse("000001000010090", "4", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal("0000010000100".split(//), nibbler.rejected)
  end

  def test_leading_number
    nibbler = Nibbler.new
    msg = nibbler.parse(0x30, "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(["3", "0"], nibbler.rejected)
  end

  def test_2_leading_numbers
    nibbler = Nibbler.new
    msg = nibbler.parse(0x60, 0x30, "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(["6", "0", "3", "0"], nibbler.rejected)
  end
  
  def test_3_leading_numbers
    nibbler = Nibbler.new
    msg = nibbler.parse(0x00, 0x30, "9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(["0", "0", "3", "0"], nibbler.rejected)
  end  
  
end
