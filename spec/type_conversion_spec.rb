# frozen_string_literal: true

require 'helper'

describe Nibbler::TypeConversion do
  describe '.hex_chars_to_numeric_bytes' do
    let(:nibbles) { %w[4 5 9 3] }
    let(:bytes) { Nibbler::TypeConversion.hex_chars_to_numeric_bytes(nibbles) }

    it "doesn't have side effects" do
      expect(nibbles).to eq(%w[4 5 9 3])
    end

    it 'returns correct bytes' do
      expect(bytes).to eq([0x45, 0x93])
    end
  end

  describe '.hex_str_to_hex_chars' do
    let(:str) { '904050' }
    let(:nibbles) { Nibbler::TypeConversion.send(:hex_str_to_hex_chars, str) }

    it "doesn't have side effects" do
      expect(str).to eq('904050')
    end

    it 'returns correct chars' do
      expect(nibbles).to eq(%w[9 0 4 0 5 0])
    end
  end

  describe '.hex_str_to_numeric_bytes' do
    let(:str) { '904050' }
    let(:bytes) { Nibbler::TypeConversion.send(:hex_str_to_numeric_bytes, str) }

    it "doesn't have side effects" do
      expect(str).to eq('904050')
    end

    it 'returns correct bytes' do
      expect(bytes).to eq([0x90, 0x40, 0x50])
    end
  end

  describe '.numeric_bytes_to_numeric_nibbles' do
    let(:bytes) { [0x90, 0x40, 0x50] }
    let(:nibbles) { Nibbler::TypeConversion.send(:numeric_bytes_to_numeric_nibbles, bytes) }

    it "doesn't have side effects" do
      expect(bytes).to eq([0x90, 0x40, 0x50])
    end

    it 'returns correct nibbles' do
      expect(nibbles).to eq([0x9, 0x0, 0x4, 0x0, 0x5, 0x0])
    end
  end

  describe '.hex_str_to_numeric_nibbles' do
    let(:str) { '904050' }
    let(:nibbles) { Nibbler::TypeConversion.send(:hex_str_to_numeric_nibbles, str) }

    it "doesn't have side effects" do
      expect(str).to eq('904050')
    end

    it 'returns correct nibbles' do
      expect(nibbles).to eq([0x9, 0x0, 0x4, 0x0, 0x5, 0x0])
    end
  end

  describe '.numeric_byte_to_numeric_nibbles' do
    let(:num) { 0x90 }
    let(:nibbles) { Nibbler::TypeConversion.send(:numeric_byte_to_numeric_nibbles, num) }

    it "doesn't have side effects" do
      expect(num).to eq(0x90)
    end

    it 'returns correct nibbles' do
      expect(nibbles).to eq([0x9, 0x0])
    end
  end

  describe '.numeric_byte_to_hex_chars' do
    let(:num) { 0x90 }
    let(:nibbles) { Nibbler::TypeConversion.send(:numeric_byte_to_hex_chars, num) }

    it "doesn't have side effects" do
      expect(num).to eq(0x90)
    end

    it 'returns correct chars' do
      expect(nibbles).to eq(%w[9 0])
    end
  end
end
