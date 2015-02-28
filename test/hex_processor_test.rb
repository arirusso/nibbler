require "helper"

class Nibbler::HexProcessorTest < Minitest::Test

  context "HexProcessor" do

    setup do
      @processor = Nibbler::HexProcessor
    end

    context "#process" do

      context "string" do

        setup do
          @str = "904050"
          @nibbles = @processor.send(:process, @str)
        end

        should "not alter input" do
          assert_equal("904050", @str)
        end

        should "return correct nibbles" do
          assert_equal(["9", "0", "4", "0", "5", "0"], @nibbles)
        end

      end

      context "numeric" do

        setup do
          @num = 0x90
          @nibbles = @processor.send(:process, @num)
        end

        should "not alter input" do
          assert_equal(0x90, @num)
        end

        should "return correct nibbles" do
          assert_equal(["9", "0"], @nibbles)
        end

      end

      context "mixed types" do

        setup do
          @array = [0x90, "90", "9"]
        end

        context "normal" do

          setup do
            @nibbles = @processor.send(:process, @array)
          end

          should "not alter input" do
            assert_equal([0x90, "90", "9"], @array)
          end

          should "return correct nibbles" do
            assert_equal(["9", "0", "9", "0", "9"], @nibbles)
          end

        end

        context "splatted" do

          setup do
            @nibbles = @processor.send(:process, *@array)
          end

          should "not alter input" do
            assert_equal([0x90, "90", "9"], @array)
          end

          should "return correct nibbles" do
            assert_equal(["9", "0", "9", "0", "9"], @nibbles)
          end

        end

      end

    end

    context "#filter_numeric" do

      context "filtered" do

        setup do
          @num = 560
          @result = @processor.send(:filter_numeric, @num)
        end

        should "not alter input" do
          assert_equal(560, @num)
        end

        should "return nil" do
          assert_nil @result
        end

      end

      context "passing" do

        setup do
          @num = 50
          @result = @processor.send(:filter_numeric, @num)
        end

        should "not alter input" do
          assert_equal(50, @num)
        end

        should "return number" do
          assert_equal(50, @result)
        end

      end

    end

    context "#filter_string" do

      setup do
        @input = "(0xAdjskla#(#"
        @result = @processor.send(:filter_string, @input)
      end

      should "not alter input" do
        assert_equal("(0xAdjskla#(#", @input)
      end

      should "return valid chars" do
        assert_equal("0ADA", @result)
      end

    end

  end

end
