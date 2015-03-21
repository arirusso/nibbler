require "helper"

class Nibbler::TypeConversionTest < Minitest::Test

  context "TypeConversion" do

    context ".hex_chars_to_numeric_bytes" do

      setup do
        @nibbles = ["4", "5", "9", "3"]
        @bytes = Nibbler::TypeConversion.hex_chars_to_numeric_bytes(@nibbles)
      end

      should "not have side effects" do
        assert_equal(["4", "5", "9", "3"], @nibbles)
      end

      should "return correct bytes" do
        assert_equal([0x45, 0x93], @bytes)
      end

    end

    context ".hex_str_to_hex_chars" do

      setup do
        @str = "904050"
        @nibbles = Nibbler::TypeConversion.send(:hex_str_to_hex_chars, @str)
      end

      should "not have side effects" do
        assert_equal("904050", @str)
      end

      should "return correct chars" do
        assert_equal(["9", "0", "4", "0", "5", "0"], @nibbles)
      end

    end

    context ".hex_str_to_numeric_bytes" do

      setup do
        @str = "904050"
        @bytes = Nibbler::TypeConversion.send(:hex_str_to_numeric_bytes, @str)
      end

      should "not have side effects" do
        assert_equal("904050", @str)
      end

      should "return correct bytes" do
        assert_equal([0x90, 0x40, 0x50], @bytes)
      end

    end

    context ".numeric_bytes_to_numeric_nibbles" do

      setup do
        @bytes = [0x90, 0x40, 0x50]
        @nibbles = Nibbler::TypeConversion.send(:numeric_bytes_to_numeric_nibbles, @bytes)
      end

      should "not have side effects" do
        assert_equal([0x90, 0x40, 0x50], @bytes)
      end

      should "return correct nibbles" do
        assert_equal([0x9, 0x0, 0x4, 0x0, 0x5, 0x0], @nibbles)
      end

    end

    context ".hex_str_to_numeric_nibbles" do

      setup do
        @str = "904050"
        @nibbles = Nibbler::TypeConversion.send(:hex_str_to_numeric_nibbles, @str)
      end

      should "not have side effects" do
        assert_equal("904050", @str)
      end

      should "return correct nibbles" do
        assert_equal([0x9, 0x0, 0x4, 0x0, 0x5, 0x0], @nibbles)
      end

    end

    context ".numeric_byte_to_numeric_nibbles" do

      setup do
        @num = 0x90
        @nibbles = Nibbler::TypeConversion.send(:numeric_byte_to_numeric_nibbles, @num)
      end

      should "not have side effects" do
        assert_equal(0x90, @num)
      end

      should "return correct nibbles" do
        assert_equal([0x9, 0x0], @nibbles)
      end

    end

    context ".numeric_byte_to_hex_chars" do

      setup do
        @num = 0x90
        @nibbles = Nibbler::TypeConversion.send(:numeric_byte_to_hex_chars, @num)
      end

      should "not have side effects" do
        assert_equal(0x90, @num)
      end

      should "return correct chars" do
        assert_equal(["9", "0"], @nibbles)
      end

    end

  end

end
