# frozen_string_literal: true

require 'helper'

describe Nibbler::DataProcessor do
  let(:processor) { Nibbler::DataProcessor }

  describe '#process' do
    let(:nibbles) { processor.send(:process, input) }

    context 'when string' do
      let(:input) { '904050' }

      it 'has no side effects' do
        expect(input).to eq('904050')
      end

      it 'returns correct nibbles' do
        expect(nibbles).to eq(%w[9 0 4 0 5 0])
      end
    end

    context 'when numeric' do
      let(:input) { 0x90 }

      it 'has no side effects' do
        expect(input).to eq(0x90)
      end

      it 'returns correct nibbles' do
        expect(nibbles).to eq(%w[9 0])
      end
    end

    context 'when mixed types' do
      let(:input) { [0x90, '90', '9'] }

      context 'normal' do
        it 'has no side effects' do
          expect(input).to eq([0x90, '90', '9'])
        end

        it 'returns correct nibbles' do
          expect(nibbles).to eq(%w[9 0 9 0 9])
        end
      end

      context 'when splatted' do
        let(:nibbles) { processor.send(:process, *input) }

        it 'has no side effects' do
          expect(input).to eq([0x90, '90', '9'])
        end

        it 'returns correct nibbles' do
          expect(nibbles).to eq(%w[9 0 9 0 9])
        end
      end
    end
  end

  describe '#filter_numeric' do
    let(:result) { processor.send(:filter_numeric, input) }

    context 'when filtered' do
      let(:input) { 560 }

      it 'has no side effects' do
        expect(input).to eq(560)
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'when passing' do
      let(:input) { 50 }

      it 'has no side effects' do
        expect(input).to eq(50)
      end

      it 'returns number' do
        expect(result).to eq(50)
      end
    end
  end

  describe '#filter_string' do
    let(:result) { processor.send(:filter_string, input) }
    let(:input) { '(0xAdjskla#(#' }

    it 'has no side effects' do
      expect(input).to eq('(0xAdjskla#(#')
    end

    it 'returns valid chars' do
      expect(result).to eq('0ADA')
    end
  end
end
