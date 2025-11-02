module Anchor
  class Base58Encoder
    BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".freeze
    BYTE_PACK_CODE = "C*".freeze
    HEX_PACK_CODE = "H*".freeze
    CHECKSUM_SIZE = 4
    BYTE_BASE = 256
    LEADING_ZERO_CHAR = "1"

    class FormatError < StandardError; end

    def base58_from_data(data)
      leading_zero_count = count_leading_zeros(data)
      integer_value = convert_bytes_to_integer(data)

      encoded_value = base58_from_int(integer_value)
      prepend_leading_zeros(encoded_value, leading_zero_count)
    end

    def base58check_from_data(data)
      checksum = generate_checksum(data)
      base58_from_data(data + checksum)
    end

    def data_from_base58(string)
      integer_value = int_from_base58(string)
      bytes = convert_integer_to_bytes(integer_value)

      binary_data = data_from_bytes(bytes)
      restore_leading_zeros(binary_data, string)
    end

    def data_from_base58check(string)
      data = data_from_base58(string)
      validate_base58check_format(string, data)

      payload_size = data.bytesize - CHECKSUM_SIZE
      payload = data[0, payload_size]
      checksum = data[payload_size, CHECKSUM_SIZE]

      validate_checksum(string, payload, checksum)
      payload
    end

    private

    def generate_checksum(data)
      hash256(data)[0, CHECKSUM_SIZE]
    end

    def validate_base58check_format(string, data)
      if data.bytesize < CHECKSUM_SIZE
        raise FormatError, "Invalid Base58Check string: too short string #{string.inspect}"
      end
    end

    def validate_checksum(string, payload, checksum)
      expected_checksum = hash256(payload)[0, CHECKSUM_SIZE]
      if checksum != expected_checksum
        raise FormatError, "Invalid Base58Check string: checksum invalid in #{string.inspect}"
      end
    end

    def count_leading_zeros(data)
      leading_zero_count = 0
      data.bytes.each do |byte|
        break if byte != 0
        leading_zero_count += 1
      end
      leading_zero_count
    end

    def convert_bytes_to_integer(data)
      integer_value = 0
      multiplier = 1

      data.bytes.reverse_each do |byte|
        integer_value += multiplier * byte unless byte == 0
        multiplier *= BYTE_BASE
      end

      integer_value
    end

    def prepend_leading_zeros(encoded_value, leading_zero_count)
      (LEADING_ZERO_CHAR * leading_zero_count) + encoded_value
    end

    def convert_integer_to_bytes(integer_value)
      bytes = []
      remaining = integer_value

      while remaining > 0
        remainder = remaining % BYTE_BASE
        remaining /= BYTE_BASE
        bytes.unshift(remainder)
      end

      bytes
    end

    def restore_leading_zeros(binary_data, base58_string)
      result = binary_data
      leading_one_byte = LEADING_ZERO_CHAR.bytes.first

      ensure_ascii_compatible_encoding(base58_string).bytes.each do |byte|
        break if byte != leading_one_byte
        result = "\x00" + result
      end

      result
    end

    def base58_from_int(integer_value)
      result = ""
      base = BASE58_ALPHABET.size
      remaining = integer_value

      while remaining > 0
        remaining, remainder = remaining.divmod(base)
        char = BASE58_ALPHABET[remainder]
        result = char + result
      end

      result
    end

    def int_from_base58(base58_string)
      result = 0
      base = BASE58_ALPHABET.size

      base58_string.reverse.each_char.with_index do |char, index|
        char_index = BASE58_ALPHABET.index(char)
        if !char_index
          raise FormatError, "Invalid Base58 character: #{char.inspect} at index #{index} (full string: #{base58_string.inspect})"
        end
        result += char_index * (base**index)
      end

      result
    end

    def sha256(data)
      Digest::SHA256.digest(data)
    end

    def hash256(data)
      sha256(sha256(data))
    end

    def ensure_ascii_compatible_encoding(string, options = nil)
      if string.encoding.ascii_compatible?
        string
      else
        string.encode(Encoding::UTF_8, options || {invalid: :replace, undef: :replace})
      end
    end

    def data_from_bytes(bytes)
      bytes.pack(BYTE_PACK_CODE)
    end
  end
end
