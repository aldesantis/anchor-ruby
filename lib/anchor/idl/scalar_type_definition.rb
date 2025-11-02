module Anchor
  module Idl
    class ScalarTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          new(type: data.to_sym.downcase)
        end
      end

      attr_reader :type
      attr_reader :base58_encoder

      def initialize(type:, base58_encoder: Anchor::Base58Encoder.new)
        @type = type
        @base58_encoder = base58_encoder
      end

      def deserialize(data, offset:, program:)
        method_name = "deserialize_#{type}"

        if respond_to?(method_name, true)
          send(method_name, data, offset)
        else
          raise ArgumentError, "Unsupported scalar type: #{type}"
        end
      end

      def serialize(value, program:)
        method_name = "serialize_#{type}"

        if respond_to?(method_name, true)
          send(method_name, value)
        else
          raise ArgumentError, "Unsupported scalar type: #{type}"
        end
      end

      private

      def check_bounds(data, offset, required_bytes)
        available_bytes = data.length - offset
        if available_bytes < required_bytes
          raise(
            DeserializationError,
            "Need #{required_bytes} bytes at offset #{offset}, but only #{available_bytes} bytes available (data length: #{data.length})"
          )
        end
      end

      def deserialize_u8(data, offset)
        check_bounds(data, offset, 1)
        bytes, new_offset = [data[offset, 1], offset + 1]
        [bytes.unpack1("C"), new_offset]
      end

      def deserialize_u16(data, offset)
        check_bounds(data, offset, 2)
        bytes, new_offset = [data[offset, 2], offset + 2]
        [bytes.unpack1("v"), new_offset] # little endian
      end

      def deserialize_u32(data, offset)
        check_bounds(data, offset, 4)
        bytes, new_offset = [data[offset, 4], offset + 4]
        [bytes.unpack1("V"), new_offset] # little endian
      end

      def deserialize_u64(data, offset)
        check_bounds(data, offset, 8)
        bytes, new_offset = [data[offset, 8], offset + 8]
        [bytes.unpack1("Q<"), new_offset] # little endian
      end

      def deserialize_i8(data, offset)
        check_bounds(data, offset, 1)
        bytes, new_offset = [data[offset, 1], offset + 1]
        [bytes.unpack1("c"), new_offset]
      end

      def deserialize_i16(data, offset)
        check_bounds(data, offset, 2)
        bytes, new_offset = [data[offset, 2], offset + 2]
        [bytes.unpack1("s<"), new_offset] # little endian signed
      end

      def deserialize_i32(data, offset)
        check_bounds(data, offset, 4)
        bytes, new_offset = [data[offset, 4], offset + 4]
        [bytes.unpack1("l<"), new_offset] # little endian signed
      end

      def deserialize_i64(data, offset)
        check_bounds(data, offset, 8)
        bytes, new_offset = [data[offset, 8], offset + 8]
        [bytes.unpack1("q<"), new_offset] # little endian signed
      end

      def deserialize_bool(data, offset)
        check_bounds(data, offset, 1)
        bytes, new_offset = [data[offset, 1], offset + 1]
        value = bytes.unpack1("C")
        [value != 0, new_offset]
      end

      def deserialize_pubkey(data, offset)
        check_bounds(data, offset, 32)
        pubkey_bytes, new_offset = [data[offset, 32], offset + 32]
        [base58_encoder.base58_from_data(pubkey_bytes), new_offset]
      end

      def deserialize_string(data, offset)
        check_bounds(data, offset, 4)
        length, new_offset = [data[offset, 4].unpack1("V"), offset + 4]
        check_bounds(data, new_offset, length)
        bytes, final_offset = [data[new_offset, length].force_encoding("UTF-8"), new_offset + length]
        [bytes, final_offset]
      end

      def deserialize_bytes(data, offset)
        check_bounds(data, offset, 4)
        length_bytes, new_offset = [data[offset, 4], offset + 4]
        length = length_bytes.unpack1("V") # little endian u32
        check_bounds(data, new_offset, length)
        [Base64.strict_encode64(data[new_offset, length]), new_offset + length]
      end

      def serialize_u8(value)
        [value].pack("C")
      end

      def serialize_u16(value)
        [value].pack("v") # little endian
      end

      def serialize_u32(value)
        [value].pack("V") # little endian
      end

      def serialize_u64(value)
        [value].pack("Q<") # little endian
      end

      def serialize_i8(value)
        [value].pack("c")
      end

      def serialize_i16(value)
        [value].pack("s<") # little endian signed
      end

      def serialize_i32(value)
        [value].pack("l<") # little endian signed
      end

      def serialize_i64(value)
        [value].pack("q<") # little endian signed
      end

      def serialize_bool(value)
        [value ? 1 : 0].pack("C")
      end

      def serialize_pubkey(value)
        base58_encoder.data_from_base58(value)
      end

      def serialize_string(value)
        utf8_bytes = value.encode("UTF-8").bytes
        length_bytes = [utf8_bytes.length].pack("V") # little endian u32
        string_bytes = utf8_bytes.pack("C*")
        length_bytes + string_bytes
      end

      def serialize_bytes(value)
        decoded_bytes = Base64.strict_decode64(value)
        length_bytes = [decoded_bytes.length].pack("V") # little endian u32
        length_bytes + decoded_bytes
      end
    end
  end
end
