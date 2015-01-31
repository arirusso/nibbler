require "helper"

class Nibbler::HexProcessorTest < Minitest::Test

  def test_to_nibbles_array_mixed
    processor = Nibbler::HexProcessor
    array = [0x90, "90", "9"]
    nibbles = processor.send(:process, array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)
  end

  def test_to_nibbles_mixed
    processor = Nibbler::HexProcessor
    array = [0x90, "90", "9"]
    nibbles = processor.send(:process, *array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)
  end

  def test_to_nibbles_numeric
    processor = Nibbler::HexProcessor
    num = 0x90
    nibbles = processor.send(:process, num)
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)
  end

  def test_to_nibbles_string
    processor = Nibbler::HexProcessor
    str = "904050"
    nibbles = processor.send(:process, str)
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)
  end

  def test_processor_numeric
    processor = Nibbler::HexProcessor
    badnum = 560
    output = processor.send(:filter_numeric, badnum)
    assert_equal(560, badnum)
    assert_equal(nil, output)
    goodnum = 50
    output = processor.send(:filter_numeric, goodnum)
    assert_equal(50, goodnum)
    assert_equal(50, output)
  end

  def test_processor_string
    processor = Nibbler::HexProcessor
    str = "(0xAdjskla#(#"
    outp = processor.send(:filter_string, str)
    assert_equal("0ADA", outp)
  end

end
