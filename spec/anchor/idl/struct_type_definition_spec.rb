# frozen_string_literal: true

RSpec.describe Anchor::Idl::StructTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe ".from_data" do
    it "creates a struct type from hash data" do
      data = {
        "kind" => "struct",
        "fields" => [
          {
            "name" => "age",
            "type" => "u8"
          },
          {
            "name" => "score",
            "type" => "u32"
          }
        ]
      }

      struct_type = described_class.from_data(data)

      expect(struct_type).to be_a(described_class)
      expect(struct_type.fields.length).to eq(2)
      expect(struct_type.find_field("age")).not_to be_nil
      expect(struct_type.find_field("score")).not_to be_nil
    end

    it "handles empty fields array" do
      data = {
        "kind" => "struct",
        "fields" => []
      }

      struct_type = described_class.from_data(data)
      expect(struct_type.fields).to eq([])
    end
  end

  describe "#deserialize" do
    it "deserializes a struct with multiple fields" do
      fields = [
        Anchor::Idl::FieldDefinition.new(
          name: "age",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
        ),
        Anchor::Idl::FieldDefinition.new(
          name: "score",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
        )
      ]

      struct_type = described_class.new(fields: fields)
      program = program_double

      # Pack: age (u8) = 25, score (u32) = 1000
      data = [25].pack("C") + [1000].pack("V")

      result, offset = struct_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq({
        "age" => 25,
        "score" => 1000
      })
      expect(offset).to eq(5)
    end

    it "handles empty struct" do
      struct_type = described_class.new(fields: [])
      program = program_double
      result, offset = struct_type.deserialize("", offset: 0, program: program)

      expect(result).to eq({})
      expect(offset).to eq(0)
    end
  end

  describe "#find_field" do
    it "finds a field by name" do
      field = Anchor::Idl::FieldDefinition.new(
        name: "test",
        type: Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      )

      struct_type = described_class.new(fields: [field])
      found = struct_type.find_field("test")

      expect(found).to eq(field)
    end

    it "returns nil for non-existent field" do
      struct_type = described_class.new(fields: [])
      found = struct_type.find_field("nonexistent")

      expect(found).to be_nil
    end
  end

  describe "#find_field!" do
    it "finds a field by name" do
      field = Anchor::Idl::FieldDefinition.new(
        name: "test",
        type: Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      )

      struct_type = described_class.new(fields: [field])
      found = struct_type.find_field!("test")

      expect(found).to eq(field)
    end

    it "raises error for non-existent field" do
      struct_type = described_class.new(fields: [])

      expect {
        struct_type.find_field!("nonexistent")
      }.to raise_error(ArgumentError, /Field nonexistent not found/)
    end
  end

  describe "#serialize" do
    it "serializes a struct with multiple fields" do
      fields = [
        Anchor::Idl::FieldDefinition.new(
          name: "age",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
        ),
        Anchor::Idl::FieldDefinition.new(
          name: "score",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
        )
      ]

      struct_type = described_class.new(fields: fields)
      program = program_double

      value = {
        "age" => 25,
        "score" => 1000
      }

      result = struct_type.serialize(value, program: program)

      # Expected: age (u8) = 25, score (u32) = 1000
      expected = [25].pack("C") + [1000].pack("V")
      expect(result).to eq(expected)
    end

    it "serializes struct with symbol keys" do
      fields = [
        Anchor::Idl::FieldDefinition.new(
          name: "age",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
        )
      ]

      struct_type = described_class.new(fields: fields)
      program = program_double

      value = {
        age: 25
      }

      result = struct_type.serialize(value, program: program)
      expect(result).to eq([25].pack("C"))
    end

    it "handles empty struct" do
      struct_type = described_class.new(fields: [])
      program = program_double
      result = struct_type.serialize({}, program: program)

      expect(result).to eq("".b)
    end
  end
end
