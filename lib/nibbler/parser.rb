#!/usr/bin/env ruby
#
# This file contains entry points for converting data in to MIDI objects
#
module MIDIMessenger
    
    class Parser
  
      #
      # convert raw midi data into objects
      #  
      # this method will take a string of hex digits and return an array of objects
      # representing MIDI and SysEx messages
      # 
      # for example...
      #
      #   inputting the string "904040b07f40b04040" will return an array containing the following objects:
      # 
      #   <MIDI::NoteOn :channel => 0, :note => 64, velocity => 64>
      #   <MIDI::ControlChange :channel => 0, :number => 127, :value => 64>  
      #   <MIDI::ControlChange :channel => 0, :number => 64, :value => 64>
      #
      def create_from_bytestr(events)
        #return nil if events.nil?

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
            # if the beginning of the hex string is something we can't deal with,
            # slice it away and go to the next
            # this may indicate some kind of buffer overflow and raising an exception might
            # turn out to be a better way to handle it
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
  
      def create_from_array(arr)
      end
  
    end
    
  
end