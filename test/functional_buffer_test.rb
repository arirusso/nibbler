require "helper"

class Nibbler::FunctionalBufferTest < Minitest::Test

  context "Parser::Buffer" do

    setup do
      @nibbler = Nibbler.new
    end

    should "have processed string nibble" do
      @nibbler.parse("9")
      assert_equal(["9"], @nibbler.buffer)
    end

    should "have processed numeric byte" do
      @nibbler.parse(0x90)
      assert_equal(["9", "0"], @nibbler.buffer)
    end

    should "have processed string byte" do
      @nibbler.parse("90")
      assert_equal(["9", "0"], @nibbler.buffer)
    end

    should "have processed array" do
      @nibbler.parse([0x90])
      assert_equal(["9", "0"], @nibbler.buffer)
    end

    should "have processed numeric bytes" do
      @nibbler.parse(0x90, 0x40)
      assert_equal(["9", "0", "4", "0"], @nibbler.buffer)
    end

    should "have processed string bytes" do
      @nibbler.parse("90", "40")
      assert_equal(["9", "0", "4", "0"], @nibbler.buffer)
    end

    should "have processed two-byte string" do
      @nibbler.parse("9040")
      assert_equal(["9", "0", "4", "0"], @nibbler.buffer)
    end

    should "have processed mixed bytes" do
      @nibbler.parse("90", 0x40)
      assert_equal(["9", "0", "4", "0"], @nibbler.buffer)
    end

    should "have processed mixed nibble and byte" do
      @nibbler.parse("9", 0x40)
      assert_equal(["9", "4", "0"], @nibbler.buffer)
    end

    should "have processed separate data" do
      @nibbler.parse("9")
      @nibbler.parse(0x40)
      assert_equal(["9", "4", "0"], @nibbler.buffer)
    end

  end

end
