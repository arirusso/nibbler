# frozen_string_literal: true

require 'helper'

describe '#buffer' do
  let(:nibbler) { Nibbler.new }

  context 'when one argument' do
    before { nibbler.parse(input) }

    context 'when string' do
      let(:input) { '9' }

      it 'processes' do
        expect(nibbler.buffer).to eq(['9'])
      end
    end

    context 'when numeric byte' do
      let(:input) { 0x90 }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0])
      end
    end

    context 'when string byte' do
      let(:input) { '90' }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0])
      end
    end

    context 'when array' do
      let(:input) { [0x90] }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0])
      end
    end

    context 'when two byte string' do
      let(:input) { '9040' }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0 4 0])
      end
    end
  end

  context 'when multiple arguments' do
    before { nibbler.parse(*input) }

    context 'when numeric bytes' do
      let(:input) { [0x90, 0x40] }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0 4 0])
      end
    end

    context 'when string bytes' do
      let(:input) { %w[90 40] }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0 4 0])
      end
    end

    context 'when mixed bytes' do
      let(:input) { ['90', 0x40] }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 0 4 0])
      end
    end

    context 'when mixed nibble and bytes' do
      let(:input) { ['9', 0x40] }

      it 'processes' do
        expect(nibbler.buffer).to eq(%w[9 4 0])
      end
    end
  end

  context 'when separate calls' do
    it 'processes' do
      nibbler.parse('9')
      nibbler.parse(0x40)

      expect(nibbler.buffer).to eq(%w[9 4 0])
    end
  end
end
