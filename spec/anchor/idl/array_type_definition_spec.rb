# frozen_string_literal: true

RSpec.describe Anchor::Idl::ArrayTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe ".from_data" do
    it "creates an array type from array data" do
      data = ["u8", 10]
      array_type = described_class.from_data(data)

      expect(array_type).to be_a(described_class)
      expect(array_type.length).to eq(10)
      expect(array_type.type).to be_a(Anchor::Idl::ScalarTypeDefinition)
      expect(array_type.type.type).to eq(:u8)
    end

    it "creates an array type with nested type" do
      data = [
        {
          "vec" => "u32"
        },
        5
      ]
      array_type = described_class.from_data(data)

      expect(array_type).to be_a(described_class)
      expect(array_type.length).to eq(5)
      expect(array_type.type).to be_a(Anchor::Idl::VecTypeDefinition)
    end
  end

  describe "#deserialize" do
    it "deserializes a fixed-length array of u8 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 3)
      program = program_double

      # Elements: [10, 20, 30]
      data = [10, 20, 30].pack("C*")

      result, offset = array_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([10, 20, 30])
      expect(offset).to eq(3)
    end

    it "deserializes a fixed-length array of u32 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      array_type = described_class.new(type: element_type, length: 2)
      program = program_double

      # Elements: [100, 200]
      data = [100, 200].pack("V*")

      result, offset = array_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([100, 200])
      expect(offset).to eq(8)
    end

    it "deserializes an empty array" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 0)
      program = program_double

      data = ""
      result, offset = array_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([])
      expect(offset).to eq(0)
    end

    it "handles offset correctly" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 2)
      program = program_double

      # Prefix data + array: [1, 2, 3, 4]
      data = [1, 2, 3, 4].pack("C*")

      result, offset = array_type.deserialize(data, offset: 2, program: program)

      expect(result).to eq([3, 4])
      expect(offset).to eq(4)
    end

    it "raises error for insufficient data" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      array_type = described_class.new(type: element_type, length: 2)
      program = program_double

      # Only 4 bytes (need 8 for 2 u32s)
      data = [1, 2, 3, 4].pack("C*")

      expect {
        array_type.deserialize(data, offset: 0, program: program)
      }.to raise_error(Anchor::Idl::DeserializationError)
    end
  end

  describe "#serialize" do
    it "serializes a fixed-length array of u8 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 3)
      program = program_double

      value = [10, 20, 30]
      result = array_type.serialize(value, program: program)

      # Elements: [10, 20, 30]
      expected = [10, 20, 30].pack("C*")
      expect(result).to eq(expected)
    end

    it "serializes a fixed-length array of u32 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      array_type = described_class.new(type: element_type, length: 2)
      program = program_double

      value = [100, 200]
      result = array_type.serialize(value, program: program)

      # Elements: [100, 200]
      expected = [100, 200].pack("V*")
      expect(result).to eq(expected)
    end

    it "serializes an empty array" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 0)
      program = program_double

      result = array_type.serialize([], program: program)
      expect(result).to eq("".b)
    end

    it "raises ArgumentError for array length mismatch" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      array_type = described_class.new(type: element_type, length: 3)
      program = program_double

      expect {
        array_type.serialize([10, 20], program: program)
      }.to raise_error(ArgumentError, /Array length mismatch.*expected 3, got 2/)
    end
  end
end
