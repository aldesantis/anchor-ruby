# frozen_string_literal: true

RSpec.describe Anchor::Idl::ScalarTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe ".from_data" do
    it "creates a scalar type from a string" do
      type = described_class.from_data("u32")
      expect(type.type).to eq(:u32)
    end

    it "converts type to lowercase symbol" do
      type = described_class.from_data("U64")
      expect(type.type).to eq(:u64)
    end
  end

  describe "#deserialize" do
    context "with u8" do
      it "deserializes unsigned 8-bit integer" do
        type = described_class.new(type: :u8)
        program = program_double
        data = [42].pack("C")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(42)
        expect(offset).to eq(1)
      end
    end

    context "with u16" do
      it "deserializes unsigned 16-bit integer (little endian)" do
        type = described_class.new(type: :u16)
        program = program_double
        data = [0x1234].pack("v")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x1234)
        expect(offset).to eq(2)
      end
    end

    context "with u32" do
      it "deserializes unsigned 32-bit integer (little endian)" do
        type = described_class.new(type: :u32)
        program = program_double
        data = [0x12345678].pack("V")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x12345678)
        expect(offset).to eq(4)
      end
    end

    context "with u64" do
      it "deserializes unsigned 64-bit integer (little endian)" do
        type = described_class.new(type: :u64)
        program = program_double
        data = [0x123456789ABCDEF0].pack("Q<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x123456789ABCDEF0)
        expect(offset).to eq(8)
      end
    end

    context "with bool" do
      it "deserializes true" do
        type = described_class.new(type: :bool)
        program = program_double
        data = [1].pack("C")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(true)
        expect(offset).to eq(1)
      end

      it "deserializes false" do
        type = described_class.new(type: :bool)
        program = program_double
        data = [0].pack("C")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(false)
        expect(offset).to eq(1)
      end
    end

    context "with string" do
      it "deserializes a string" do
        type = described_class.new(type: :string)
        program = program_double
        str = "Hello"
        data = [str.length].pack("V") + str
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq("Hello")
        expect(offset).to eq(9)
      end

      it "deserializes an empty string" do
        type = described_class.new(type: :string)
        program = program_double
        data = [0].pack("V")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq("")
        expect(offset).to eq(4)
      end
    end

    context "with pubkey" do
      it "deserializes a public key to Base58" do
        type = described_class.new(type: :pubkey)
        program = program_double
        # 32 bytes of data
        pubkey_bytes = "a" * 32
        value, offset = type.deserialize(pubkey_bytes, offset: 0, program: program)
        expect(value).to be_a(String)
        expect(offset).to eq(32)
      end
    end

    context "with i8" do
      it "deserializes signed 8-bit integer" do
        type = described_class.new(type: :i8)
        program = program_double
        data = [42].pack("c")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(42)
        expect(offset).to eq(1)
      end

      it "deserializes negative signed 8-bit integer" do
        type = described_class.new(type: :i8)
        program = program_double
        data = [-42].pack("c")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(-42)
        expect(offset).to eq(1)
      end
    end

    context "with i16" do
      it "deserializes signed 16-bit integer (little endian)" do
        type = described_class.new(type: :i16)
        program = program_double
        data = [0x1234].pack("s<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x1234)
        expect(offset).to eq(2)
      end

      it "deserializes negative signed 16-bit integer" do
        type = described_class.new(type: :i16)
        program = program_double
        data = [-1000].pack("s<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(-1000)
        expect(offset).to eq(2)
      end
    end

    context "with i32" do
      it "deserializes signed 32-bit integer (little endian)" do
        type = described_class.new(type: :i32)
        program = program_double
        data = [0x12345678].pack("l<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x12345678)
        expect(offset).to eq(4)
      end

      it "deserializes negative signed 32-bit integer" do
        type = described_class.new(type: :i32)
        program = program_double
        data = [-1000000].pack("l<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(-1000000)
        expect(offset).to eq(4)
      end
    end

    context "with i64" do
      it "deserializes signed 64-bit integer (little endian)" do
        type = described_class.new(type: :i64)
        program = program_double
        data = [0x123456789ABCDEF0].pack("q<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(0x123456789ABCDEF0)
        expect(offset).to eq(8)
      end

      it "deserializes negative signed 64-bit integer" do
        type = described_class.new(type: :i64)
        program = program_double
        data = [-1000000000000].pack("q<")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(-1000000000000)
        expect(offset).to eq(8)
      end
    end

    context "with bytes" do
      it "deserializes bytes to Base64" do
        type = described_class.new(type: :bytes)
        program = program_double
        bytes_data = "Hello, World!"
        data = [bytes_data.length].pack("V") + bytes_data
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(Base64.strict_encode64(bytes_data))
        expect(offset).to eq(4 + bytes_data.length)
      end

      it "deserializes empty bytes" do
        type = described_class.new(type: :bytes)
        program = program_double
        data = [0].pack("V")
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(Base64.strict_encode64(""))
        expect(offset).to eq(4)
      end

      it "deserializes binary data" do
        type = described_class.new(type: :bytes)
        program = program_double
        bytes_data = [0, 1, 2, 255, 254, 253].pack("C*")
        data = [bytes_data.length].pack("V") + bytes_data
        value, offset = type.deserialize(data, offset: 0, program: program)
        expect(value).to eq(Base64.strict_encode64(bytes_data))
        expect(offset).to eq(4 + bytes_data.length)
      end
    end

    context "with unsupported type" do
      it "raises an error" do
        type = described_class.new(type: :invalid)
        program = program_double
        data = [42].pack("C")
        expect {
          type.deserialize(data, offset: 0, program: program)
        }.to raise_error(ArgumentError, /Unsupported scalar type/)
      end
    end

    context "with insufficient data" do
      it "raises DeserializationError" do
        type = described_class.new(type: :u32)
        program = program_double
        data = [1, 2].pack("C*")
        expect {
          type.deserialize(data, offset: 0, program: program)
        }.to raise_error(Anchor::Idl::DeserializationError, /Need 4 bytes/)
      end
    end
  end

  describe "#serialize" do
    context "with u8" do
      it "serializes unsigned 8-bit integer" do
        type = described_class.new(type: :u8)
        program = program_double
        result = type.serialize(42, program: program)
        expect(result).to eq([42].pack("C"))
      end
    end

    context "with u16" do
      it "serializes unsigned 16-bit integer (little endian)" do
        type = described_class.new(type: :u16)
        program = program_double
        result = type.serialize(0x1234, program: program)
        expect(result).to eq([0x1234].pack("v"))
      end
    end

    context "with u32" do
      it "serializes unsigned 32-bit integer (little endian)" do
        type = described_class.new(type: :u32)
        program = program_double
        result = type.serialize(0x12345678, program: program)
        expect(result).to eq([0x12345678].pack("V"))
      end
    end

    context "with u64" do
      it "serializes unsigned 64-bit integer (little endian)" do
        type = described_class.new(type: :u64)
        program = program_double
        result = type.serialize(0x123456789ABCDEF0, program: program)
        expect(result).to eq([0x123456789ABCDEF0].pack("Q<"))
      end
    end

    context "with bool" do
      it "serializes true" do
        type = described_class.new(type: :bool)
        program = program_double
        result = type.serialize(true, program: program)
        expect(result).to eq([1].pack("C"))
      end

      it "serializes false" do
        type = described_class.new(type: :bool)
        program = program_double
        result = type.serialize(false, program: program)
        expect(result).to eq([0].pack("C"))
      end
    end

    context "with string" do
      it "serializes a string" do
        type = described_class.new(type: :string)
        program = program_double
        str = "Hello"
        result = type.serialize(str, program: program)
        expected = [str.length].pack("V") + str
        expect(result).to eq(expected)
      end

      it "serializes an empty string" do
        type = described_class.new(type: :string)
        program = program_double
        result = type.serialize("", program: program)
        expect(result).to eq([0].pack("V"))
      end
    end

    context "with pubkey" do
      it "serializes a Base58 public key to 32 bytes" do
        type = described_class.new(type: :pubkey)
        program = program_double
        # 32 bytes of data
        pubkey_bytes = "a" * 32
        base58_value = type.base58_encoder.base58_from_data(pubkey_bytes)
        result = type.serialize(base58_value, program: program)
        expect(result).to eq(pubkey_bytes)
        expect(result.length).to eq(32)
      end
    end

    context "with i8" do
      it "serializes signed 8-bit integer" do
        type = described_class.new(type: :i8)
        program = program_double
        result = type.serialize(42, program: program)
        expect(result).to eq([42].pack("c"))
      end

      it "serializes negative signed 8-bit integer" do
        type = described_class.new(type: :i8)
        program = program_double
        result = type.serialize(-42, program: program)
        expect(result).to eq([-42].pack("c"))
      end
    end

    context "with i16" do
      it "serializes signed 16-bit integer (little endian)" do
        type = described_class.new(type: :i16)
        program = program_double
        result = type.serialize(0x1234, program: program)
        expect(result).to eq([0x1234].pack("s<"))
      end

      it "serializes negative signed 16-bit integer" do
        type = described_class.new(type: :i16)
        program = program_double
        result = type.serialize(-1000, program: program)
        expect(result).to eq([-1000].pack("s<"))
      end
    end

    context "with i32" do
      it "serializes signed 32-bit integer (little endian)" do
        type = described_class.new(type: :i32)
        program = program_double
        result = type.serialize(0x12345678, program: program)
        expect(result).to eq([0x12345678].pack("l<"))
      end

      it "serializes negative signed 32-bit integer" do
        type = described_class.new(type: :i32)
        program = program_double
        result = type.serialize(-1000000, program: program)
        expect(result).to eq([-1000000].pack("l<"))
      end
    end

    context "with i64" do
      it "serializes signed 64-bit integer (little endian)" do
        type = described_class.new(type: :i64)
        program = program_double
        result = type.serialize(0x123456789ABCDEF0, program: program)
        expect(result).to eq([0x123456789ABCDEF0].pack("q<"))
      end

      it "serializes negative signed 64-bit integer" do
        type = described_class.new(type: :i64)
        program = program_double
        result = type.serialize(-1000000000000, program: program)
        expect(result).to eq([-1000000000000].pack("q<"))
      end
    end

    context "with bytes" do
      it "serializes Base64 string to bytes with length prefix" do
        type = described_class.new(type: :bytes)
        program = program_double
        bytes_data = "Hello, World!"
        base64_value = Base64.strict_encode64(bytes_data)
        result = type.serialize(base64_value, program: program)
        expected = [bytes_data.length].pack("V") + bytes_data
        expect(result).to eq(expected)
      end

      it "serializes empty bytes" do
        type = described_class.new(type: :bytes)
        program = program_double
        base64_value = Base64.strict_encode64("")
        result = type.serialize(base64_value, program: program)
        expect(result).to eq([0].pack("V"))
      end

      it "serializes binary data" do
        type = described_class.new(type: :bytes)
        program = program_double
        bytes_data = [0, 1, 2, 255, 254, 253].pack("C*")
        base64_value = Base64.strict_encode64(bytes_data)
        result = type.serialize(base64_value, program: program)
        expected = [bytes_data.length].pack("V") + bytes_data
        expect(result).to eq(expected)
      end
    end

    context "with unsupported type" do
      it "raises an error" do
        type = described_class.new(type: :invalid)
        program = program_double
        expect {
          type.serialize(42, program: program)
        }.to raise_error(ArgumentError, /Unsupported scalar type/)
      end
    end
  end
end
