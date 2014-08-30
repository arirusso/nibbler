require "helper"

class NibblerTest < Test::Unit::TestCase
    
  def test_varying_length_strings
    nibbler = Nibbler.new
    msg = nibbler.parse("9", "04", "040")
    assert_equal(MIDIMessage::NoteOn, msg.class)
  end
  
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
  
  def test_timestamp
    nibbler = Nibbler.new
    stamp = Time.now.to_i
    outp = nibbler.parse(0x90, 0x40, 0x40, :timestamp => stamp)
    msg = outp[:messages]
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)
    assert_equal(stamp, outp[:timestamp])      
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
    assert_equal(0x20, msg.index)
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
    
  def test_pitch_bend
    nibbler = Nibbler.new
    msg = nibbler.parse(0xE0, 0x20, 0x00) # center
    assert_equal(MIDIMessage::PitchBend, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x20, msg.low)
    assert_equal(0x00, msg.high)  
  end   
   
  def test_system_common_generic_3_bytes
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1, 0x50, 0xA0)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
    assert_equal(0x50, msg.data[0])
    assert_equal(0xA0, msg.data[1])  
  end    

  def test_system_common_generic_2_bytes
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1, 0x50)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
    assert_equal(0x50, msg.data[0])  
  end    

  def test_system_common_generic_1_byte
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
  end    
  
  def test_system_realtime
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF8)
    assert_equal(MIDIMessage::SystemRealtime, msg.class)
    assert_equal(8, msg.id)
  end
                 
end
