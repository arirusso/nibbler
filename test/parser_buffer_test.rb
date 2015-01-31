require "helper"

class Nibbler::BufferTest < Minitest::Test

  def test_buffer_nibble_str
    nibbler = Nibbler.new
    nibbler.parse("9")
    assert_equal(["9"], nibbler.buffer)
  end

  def test_buffer_single_byte
    nibbler = Nibbler.new
    nibbler.parse(0x90)
    assert_equal(["9", "0"], nibbler.buffer)
  end

  def test_buffer_single_byte_str
    nibbler = Nibbler.new
    nibbler.parse("90")
    assert_equal(["9", "0"], nibbler.buffer)
  end

  def test_buffer_single_byte_in_array
    nibbler = Nibbler.new
    nibbler.parse([0x90])
    assert_equal(["9", "0"], nibbler.buffer)
  end

  def test_buffer_two_bytes
    nibbler = Nibbler.new
    nibbler.parse(0x90, 0x40)
    assert_equal(["9", "0", "4", "0"], nibbler.buffer)
  end

  def test_buffer_two_bytes_str
    nibbler = Nibbler.new
    nibbler.parse("90", "40")
    assert_equal(["9", "0", "4", "0"], nibbler.buffer)
  end

  def test_buffer_two_bytes_single_str
    nibbler = Nibbler.new
    nibbler.parse("9040")
    assert_equal(["9", "0", "4", "0"], nibbler.buffer)
  end

  def test_buffer_two_bytes_mixed
    nibbler = Nibbler.new
    nibbler.parse("90", 0x40)
    assert_equal(["9", "0", "4", "0"], nibbler.buffer)
  end

  def test_buffer_nibble_and_byte_mixed
    nibbler = Nibbler.new
    nibbler.parse("9", 0x40)
    assert_equal(["9", "4", "0"], nibbler.buffer)
  end

  def test_buffer_stepped
    nibbler = Nibbler.new
    nibbler.parse("9")
    nibbler.parse(0x40)
    assert_equal(["9", "4", "0"], nibbler.buffer)
  end

end
