# frozen_string_literal: true

require 'helper'

describe Nibbler::StringConversion do
  let(:output) { Nibbler::StringConversion.convert_strings_to_numeric_bytes(*input) }

  describe '#process' do
    context 'when bytes' do
      let(:input) { ["90", "40", "50"] }

      it 'returns correct bytes' do
        expect(output).to eq([0x90, 0x40, 0x50])
      end
    end

    context 'when full string' do
      let(:input) { ["904050"] }

      it 'returns correct bytes' do
        expect(output).to eq([0x90, 0x40, 0x50])
      end
    end
  end
end
