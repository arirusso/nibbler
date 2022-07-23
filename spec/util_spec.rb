# frozen_string_literal: true

require 'helper'

describe Nibbler::Util do
  describe '.numeric_byte_to_numeric_nibbles' do
    let(:num) { 0x90 }
    let(:nibbles) { Nibbler::Util.send(:numeric_byte_to_numeric_nibbles, num) }

    it "doesn't have side effects" do
      expect(num).to eq(0x90)
    end

    it 'returns correct nibbles' do
      expect(nibbles).to eq([0x9, 0x0])
    end
  end
end
