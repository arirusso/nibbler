# frozen_string_literal: true

require 'helper'

describe Nibbler::Util do
  describe 'Conversion' do
    describe '.strings_to_numeric_bytes' do
      let(:output) { Nibbler::Util::Conversion.send(:strings_to_numeric_bytes, *input) }

      context 'when bytes' do
        let(:input) { %w[90 40 50] }

        it 'returns correct bytes' do
          expect(output).to eq([0x90, 0x40, 0x50])
        end
      end

      context 'when full string' do
        let(:input) { ['904050'] }

        it 'returns correct bytes' do
          expect(output).to eq([0x90, 0x40, 0x50])
        end
      end
    end

    describe '.numeric_byte_to_numeric_nibbles' do
      let(:num) { 0x90 }
      let(:nibbles) { Nibbler::Util::Conversion.send(:numeric_byte_to_numeric_nibbles, num) }

      it "doesn't have side effects" do
        expect(num).to eq(0x90)
      end

      it 'returns correct nibbles' do
        expect(nibbles).to eq([0x9, 0x0])
      end
    end
  end
end
