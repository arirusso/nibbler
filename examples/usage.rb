#!/usr/bin/env ruby
#
# Walk through of different ways to use Nibbler
#

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'nibbler'
require 'pp'



nibbler = Nibbler.new

pp "Enter a message piece by piece"

pp nibbler.parse("90")

pp nibbler.parse("40")

pp nibbler.parse("40")

pp "Enter a message all at once"

pp nibbler.parse("904040")

pp "Use Bytes"

pp nibbler.parse(0x90, 0x40, 0x40) # this should return a message

pp "Use nibbles in string format"

pp nibbler.parse("9", "0", 0x40, 0x40) # this should return a message

pp "Interchange the different types"
  
pp nibbler.parse("9", "0", 0x40, 64)
  
pp "Use running status"

pp nibbler.parse(0x40, 64)
  
pp "Look at the messages we've parsed"

pp nibbler.messages # this should return an array of messages

pp "Add an incomplete message"

pp nibbler.parse("9")
pp nibbler.parse("40")

pp "See progress"

pp nibbler.buffer # should give you an array of bits

pp nibbler.buffer_s # should give you an array of bytestrs

pp "Pass in a timestamp"

# note:
# once you pass in a timestamp for the first time, nibbler.messages will then return 
# an array of message/timestamp hashes
# if there was no timestamp for a particular message it will be nil
#

pp nibbler.parse("904040", :timestamp => Time.now.to_i)

pp "Add callbacks"

# you can list any properties of the message to check against. 
# if they are all true, the callback will fire
#
# if you wish to use "or" or any more advanced matching I would just process the message after it's
# returned
#
nibbler.when({ :class => MIDIMessage::NoteOn }) { |msg| puts "bark" } 
pp nibbler.parse("904040")
pp nibbler.parse("804040")

pp "Generate midilib messages"

midilib_nibbler = Nibbler.new(:message_lib => :midilib)
  
pp midilib_nibbler.parse("9", "0", 0x40, "40")
