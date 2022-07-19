
CHANNEL_MESSAGE_TYPES = [
  {
    status: 0x8,
    name: :note_off,
    length_in_bytes: 3
  },
  {
    status: 0x9,
    name: :note_on,
    length_in_bytes: 3
  },
  {
    status: 0xA,
    name: :polyphonic_aftertouch,
    length_in_bytes: 3
  },
  {
    status: 0xB,
    name: :control_change,
    length_in_bytes: 3
  },
  {
    status: 0xC,
    name: :program_change,
    length_in_bytes: 2
  },
  {
    status: 0xD,
    name: :channel_aftertouch,
    length_in_bytes: 2
  },
  {
    status: 0xE,
    name: :pitch_bend,
    length_in_bytes: 3
  }
].freeze

def numeric_byte_to_numeric_nibbles(num)
  [((num & 0xF0) >> 4), (num & 0x0F)]
end

def message_type(status_byte)
  CHANNEL_MESSAGE_TYPES.find do |type|
    type[:status] === numeric_byte_to_numeric_nibbles(status_byte)[0]
  end
end

def status_bit(byte)
  # ruby binary goes least to most significant thus 7 and not 0
  byte[7]
end

def is_status_byte?(byte)
  status_bit(byte) === 1
end

Report = Struct.new(:messages, :other)

def process(bytes)
  report = Report.new([], [])
  pointer = 0
  while pointer <= bytes.length - 1
    if is_status_byte?(bytes[pointer])
      type = message_type(bytes[pointer])
      message = bytes.slice(pointer, type[:length_in_bytes])
      if message.length < type[:length_in_bytes]
        # message is incomplete
        report.other += message
      else
        report.messages << message
      end
      pointer += type[:length_in_bytes]
    else
      report.other << bytes[pointer]
      pointer += 1
    end
  end
  report
end


# test data breaks down to this:
# 
# leading byte: 0x10
# message: [0x90, 0x40, 0x40] (note on message)
# message: [0xB2, 0x01, 0x02] (control change)
# incomplete message: 0xC0
# 
test_data = [0x10, 0x90, 0x40, 0x40, 0xB2, 0x01, 0x02, 0xC0]
result = process(test_data)

pp result

raise if result != Report.new([[0x90, 0x40, 0x40], [0xB2, 0x01, 0x02]], [0x10, 0xC0])