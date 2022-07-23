# Nibbler

![nibbler](http://i.imgur.com/4BFZPJY.png)

Parse MIDI Messages

## Install

`gem install midi-nibbler`

or using Bundler, add this to your Gemfile

`gem 'midi-nibbler'`

## Usage

```ruby
require 'nibbler'

nibbler = Nibbler.new
```

Enter a MIDI message represented as numeric bytes

```ruby
nibbler.parse(0x90, 0x40, 0x64)

  => #<MIDIMessage::NoteOn:0x98c9818
        @channel=0,
        @data=[64, 100],
        @name="C3",
        @note=64,
        @status=[9, 0],
        @velocity=100,
        @verbose_name="Note On: C3">
```

Enter a message byte by byte

```ruby
nibbler.parse(0x90)
  => nil

nibbler.parse(0x40)
  => nil

nibbler.parse(0x64)
  => #<MIDIMessage::NoteOn:0x98c9818
       @channel=0,
       @data=[64, 100],
       @name="C3",
       @note=64,
       @status=[9, 0],
       @velocity=100,
       @verbose_name="Note On: C3">
```

Enter the message as a string

```ruby
nibbler.parse_s('904064')
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Use string bytes

```ruby
nibbler.parse_s('90', '40', '64')
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Use running status

```ruby
nibbler.parse(0x40, 100)
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Look at the messages we've parsed so far

```ruby
nibbler.messages
  => [#<MIDIMessage::NoteOn:0x98c9804 ...>
      #<MIDIMessage::NoteOn:0x98c9811 ...>]
```

Add an incomplete message

```ruby
nibbler.parse('90')
nibbler.parse('40')
```

See progress

```ruby
nibbler.buffer
  => ["9", "0", "4", "0"]

nibbler.buffer_s
  => "9040"
```

Pass in a timestamp

```ruby
nibbler.parse('904064', timestamp: Time.now.to_i)
  => { :messages=> #<MIDIMessage::NoteOn:0x92f4564 ..>, :timestamp=>1304488440 }
```

Nibbler defaults to generate [midi-message](http://github.com/arirusso/midi-message) objects, but it's also possible to use [midilib](https://github.com/jimm/midilib)

```ruby
Nibbler.new(message_lib: :midilib)

nibbler.parse(0x90, 0x40, 0x40)
  => "0: ch 00 on 40 40"
```

## Also see

* [midi-eye](http://github.com/arirusso/midi-eye), a MIDI event listener based on nibbler

## Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2022 Ari Russo
