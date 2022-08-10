# frozen_string_literal: true

require 'helper'

describe Nibbler::MessageBuilder do
  let(:library) { Nibbler::MessageLibrary.adapter }

  describe '#sysex_length' do
    let(:builder) { Nibbler::MessageBuilder.for_system_exclusive(library) }
    let(:result) { builder.sysex_length(bytes) }

    context 'when incomplete with no end byte' do
      let(:bytes) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0x50] }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'when has extra bytes' do
      let(:bytes) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7, 0x90, 0x50] }

      it 'returns length including the end status (0xF7)' do
        expect(result).to eq(11)
      end
    end
  end

  describe '#can_build_next?' do
    context 'when channel message' do
      let(:builder) { Nibbler::MessageBuilder.for_channel_message(library, status_nibble) }

      context 'when basic' do
        let(:result) { builder.can_build_next?(bytes) }

        context 'when valid' do
          let(:bytes) { [0x90, 0x40, 0x40] }
          let(:status_nibble) { 0x9 }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end

        context 'when has extra bytes' do
          let(:bytes) { [0x90, 0x40, 0x40, 0x50] }
          let(:status_nibble) { 0x9 }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end

        context 'when followed by another message' do
          let(:bytes) { [0x90, 0x40, 0x40, 0x90] }
          let(:status_nibble) { 0x9 }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end

        context 'when incomplete' do
          let(:bytes) { [0x90, 0x40] }
          let(:status_nibble) { 0x9 }

          it 'returns false' do
            expect(result).to eq(false)
          end
        end

        context 'when invalid' do
          let(:bytes) { [0x90, 0x40, 0x80] }
          let(:status_nibble) { 0x9 }

          it 'returns false' do
            expect(result).to eq(false)
          end
        end
      end
    end

    context 'when sysex message' do
      let(:builder) { Nibbler::MessageBuilder.for_system_exclusive(library) }

      context 'when basic' do
        let(:result) { builder.can_build_next?(bytes) }

        context 'when valid' do
          let(:bytes) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7] }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end

        context 'when incomplete with no end byte' do
          let(:bytes) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0x50] }

          it 'returns false' do
            expect(result).to eq(false)
          end
        end

        context 'when has extra bytes' do
          let(:bytes) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7, 0x90, 0x50] }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end
      end
    end

    context 'when other system message' do
      let(:builder) { Nibbler::MessageBuilder.for_system_message(library, status_nibble) }

      context 'when basic' do
        let(:result) { builder.can_build_next?(bytes) }

        context 'when valid' do
          let(:bytes) { [0xF1, 0x50] }
          let(:status_nibble) { 0x1 }

          it 'returns true' do
            expect(result).to eq(true)
          end
        end

        context 'when incomplete' do
          let(:bytes) { [0xF1] }
          let(:status_nibble) { 0x1 }

          it 'returns false' do
            expect(result).to eq(false)
          end
        end

        context 'when invalid' do
          let(:bytes) { [0xF1, 0x80] }
          let(:status_nibble) { 0x1 }

          it 'returns false' do
            expect(result).to eq(false)
          end
        end
      end
    end
  end
end
