#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

#
# Walk through different ways to use Nibbler
#

require 'nibbler'

nibbler = Nibbler.new

pp 'Enter a message using numeric bytes'

pp nibbler.parse(0x90, 0x40, 0x40) # this should return a message

pp 'Go byte by byte'

pp nibbler.parse(0x90)

pp nibbler.parse(0x40)

pp nibbler.parse(0x40) # this should return a message

pp "There's also a method to parse a string"

pp nibbler.parse_s('904040') # this should return a message

pp "You can also go byte by byte with strings"

pp nibbler.parse_s('90')

pp nibbler.parse_s('40')

pp nibbler.parse_s('40') # this should return a message

pp 'Use running status'

pp nibbler.parse(0x40, 64) # this should return a message

pp "Look at the messages we've parsed"

pp nibbler.events

pp 'Add an incomplete message'

pp nibbler.parse_s('90')
pp nibbler.parse_s('40')

pp 'See progress'

pp nibbler.buffer # should give you an array of bytes

pp 'Pass in a timestamp'

pp nibbler.parse_s('904040', timestamp: Time.now.to_i)

pp 'Generate midilib messages'

midilib_nibbler = Nibbler.new(message_lib: :midilib)

pp midilib_nibbler.parse(0x90, 0x40, 0x40)
