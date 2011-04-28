#!/usr/bin/env ruby

require 'midi-message'

module Nibbler
  
  VERSION = "0.0.1"

  class Parser

    include MIDIMessage
  
    def parse_bytestr(string)

        objects = []
        hex_digits = events.first[:data]
        until hex_digits.nil? || hex_digits.eql?('') || hex_digits.eql?('00') || hex_digits.eql?(0)
          status = hex_digits[0,2]
          msg_class = case status[0].hex
            when 0x8 then NoteOff
            when 0x9 then NoteOn
            when 0xA then PolyphonicAftertouch
            when 0xB then ControlChange
            when 0xC then ProgramChange
            when 0xD then ChannelAftertouch
            when 0xE then PitchBend
            when 0xF then case status[1].hex
              when 0x0 then SystemExclusive
              when 0x1..0x6 then SystemCommon
              when 0x8..0xF then SystemRealtime
            end
          end
          if msg_class.nil?
          hex_digits.slice!(0,2)
        else
          result = msg_class.create_from_bytestr(hex_digits)
          unless result.nil?
            hex_digits = result[:remaining_hex_digits]
            objects << result[:object]
          end
        end
      end
      objects
    end
  
    def parse_bytes(*bytes)
    end
  
  end

  def self.new
    Parser.new
  end

end
	
