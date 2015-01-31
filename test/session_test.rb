require "helper"

class Nibbler::SessionTest < Minitest::Test

  def test_varying_length_strings
    session = Nibbler::Session.new
    message = session.parse("9", "04", "040")

    refute_nil message
    assert_equal(MIDIMessage::NoteOn, message.class)
  end

  def test_note_off
    session = Nibbler::Session.new
    message = session.parse(0x80, 0x40, 0x40)

    refute_nil message
    assert_equal(MIDIMessage::NoteOff, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)
  end

  def test_note_on
    session = Nibbler::Session.new
    message = session.parse(0x90, 0x40, 0x40)

    refute_nil message
    assert_equal(MIDIMessage::NoteOn, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)
  end

  def test_timestamp
    session = Nibbler::Session.new
    stamp = Time.now.to_i
    report = session.parse(0x90, 0x40, 0x40, :timestamp => stamp)
    message = report[:messages]

    refute_nil message
    assert_equal(MIDIMessage::NoteOn, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)
    assert_equal(stamp, report[:timestamp])
  end

  def test_polyphonic_aftertouch
    session = Nibbler::Session.new
    message = session.parse(0xA1, 0x40, 0x40)

    refute_nil message
    assert_equal(MIDIMessage::PolyphonicAftertouch, message.class)
    assert_equal(1, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.value)
  end

  def test_control_change
    session = Nibbler::Session.new
    message = session.parse(0xB2, 0x20, 0x20)

    refute_nil message
    assert_equal(MIDIMessage::ControlChange, message.class)
    assert_equal(message.channel, 2)
    assert_equal(0x20, message.index)
    assert_equal(0x20, message.value)
  end

  def test_program_change
    session = Nibbler::Session.new
    message = session.parse(0xC3, 0x40)

    refute_nil message
    assert_equal(MIDIMessage::ProgramChange, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x40, message.program)
  end

  def test_channel_aftertouch
    session = Nibbler::Session.new
    message = session.parse(0xD3, 0x50)

    refute_nil message
    assert_equal(MIDIMessage::ChannelAftertouch, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x50, message.value)
  end

  def test_pitch_bend
    session = Nibbler::Session.new
    message = session.parse(0xE0, 0x20, 0x00) # center

    refute_nil message
    assert_equal(MIDIMessage::PitchBend, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x20, message.low)
    assert_equal(0x00, message.high)
  end

  def test_system_common_generic_3_bytes
    session = Nibbler::Session.new
    message = session.parse(0xF1, 0x50, 0xA0)

    refute_nil message
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])
    assert_equal(0xA0, message.data[1])
  end

  def test_system_common_generic_2_bytes
    session = Nibbler::Session.new
    message = session.parse(0xF1, 0x50)
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])
  end

  def test_system_common_generic_1_byte
    session = Nibbler::Session.new
    message = session.parse(0xF1)
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
  end

  def test_system_realtime
    session = Nibbler::Session.new
    message = session.parse(0xF8)
    assert_equal(MIDIMessage::SystemRealtime, message.class)
    assert_equal(8, message.id)
  end

end
