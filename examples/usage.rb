#!/usr/bin/env ruby
#
# Walk through of different ways to use Nibbler
#

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'nibbler'
require 'pp'

nibbler = Nibbler.new

# Enter a message piece by piece

pp nibbler.parse("90")

pp nibbler.parse("40")

pp nibbler.parse("40") # this should return a message

# Enter a message all at once

pp nibbler.parse("904040") # this should return a message

#  Use bytes

pp nibbler.parse(0x90, 0x40, 0x40) # this should return a message

# Use nibbles

pp nibbler.parse("9", "0", 0x40, 0x40) # this should return a message

# Use nibbles and bytes and strings

pp nibbler.parse("9", "0", "4040") # this should return a message

# Look at the messages we’ve parsed

p nibbler.messages # this should return an array of messages

# Add an incomplete message

pp nibbler.parse("9")
pp nibbler.parse("40")

#See progress

pp nibbler.buffer # should give you an array of bits

pp nibbler.buffer_hex # should give you an array of bytestrs