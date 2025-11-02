# frozen_string_literal: true

RSpec.describe Anchor::Idl::EnumTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe ".from_data" do
    it "creates an enum type from hash data" do
      data = {
        "variants" => [
          {
            "name" => "Variant1",
            "fields" => []
          },
          {
            "name" => "Variant2",
            "fields" => [
              {
                "name" => "value",
                "type" => "u32"
              }
            ]
          }
        ]
      }

      enum_type = described_class.from_data(data)

      expect(enum_type).to be_a(described_class)
      expect(enum_type.variants.length).to eq(2)
      expect(enum_type.variants[0].name).to eq("Variant1")
      expect(enum_type.variants[1].name).to eq("Variant2")
      expect(enum_type.variants[1].fields.length).to eq(1)
    end

    it "handles enum variants without fields" do
      data = {
        "variants" => [
          {
            "name" => "EmptyVariant"
          }
        ]
      }

      enum_type = described_class.from_data(data)
      expect(enum_type.variants[0].fields).to eq([])
    end
  end

  describe "#deserialize" do
    it "deserializes an enum with a variant that has no fields" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      variant2 = Anchor::Idl::VariantDefinition.new(
        name: "Variant2",
        fields: [
          Anchor::Idl::FieldDefinition.new(
            name: "value",
            type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
          )
        ]
      )

      enum_type = described_class.new(variants: [variant1, variant2])
      program = program_double

      # Discriminant: 0 (Variant1)
      data = [0].pack("C")
      result, offset = enum_type.deserialize(data, offset: 0, program: program)

      expect(result[:variant]).to eq("Variant1")
      expect(result[:data]).to eq({})
      expect(offset).to eq(1)
    end

    it "deserializes an enum with a variant that has fields" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      variant2 = Anchor::Idl::VariantDefinition.new(
        name: "Variant2",
        fields: [
          Anchor::Idl::FieldDefinition.new(
            name: "value",
            type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
          )
        ]
      )

      enum_type = described_class.new(variants: [variant1, variant2])
      program = program_double

      # Discriminant: 1 (Variant2), Value: 42
      data = [1].pack("C") + [42].pack("V")
      result, offset = enum_type.deserialize(data, offset: 0, program: program)

      expect(result[:variant]).to eq("Variant2")
      expect(result[:data]).to eq({"value" => 42})
      expect(offset).to eq(5)
    end

    it "raises DeserializationError for invalid discriminant (negative)" do
      enum_type = described_class.new(variants: [])
      program = program_double
      data = [255].pack("C") # -1 as signed byte

      expect {
        enum_type.deserialize(data, offset: 0, program: program)
      }.to raise_error(Anchor::Idl::DeserializationError, /Invalid enum discriminant/)
    end

    it "raises DeserializationError for invalid discriminant (too large)" do
      variant = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      enum_type = described_class.new(variants: [variant])
      program = program_double
      data = [1].pack("C") # Discriminant 1, but only 0 exists

      expect {
        enum_type.deserialize(data, offset: 0, program: program)
      }.to raise_error(Anchor::Idl::DeserializationError, /Invalid enum discriminant.*expected 0\.\.0, got 1/)
    end

    it "raises DeserializationError for insufficient data" do
      enum_type = described_class.new(variants: [])
      program = program_double
      data = ""

      expect {
        enum_type.deserialize(data, offset: 0, program: program)
      }.to raise_error(Anchor::Idl::DeserializationError)
    end
  end

  describe "#serialize" do
    it "serializes an enum with a variant that has no fields" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      variant2 = Anchor::Idl::VariantDefinition.new(
        name: "Variant2",
        fields: [
          Anchor::Idl::FieldDefinition.new(
            name: "value",
            type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
          )
        ]
      )

      enum_type = described_class.new(variants: [variant1, variant2])
      program = program_double

      value = {variant: "Variant1", data: {}}
      result = enum_type.serialize(value, program: program)

      # Discriminant: 0 (Variant1)
      expect(result).to eq([0].pack("C"))
    end

    it "serializes an enum with a variant that has fields" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      variant2 = Anchor::Idl::VariantDefinition.new(
        name: "Variant2",
        fields: [
          Anchor::Idl::FieldDefinition.new(
            name: "value",
            type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
          )
        ]
      )

      enum_type = described_class.new(variants: [variant1, variant2])
      program = program_double

      value = {variant: "Variant2", data: {"value" => 42}}
      result = enum_type.serialize(value, program: program)

      # Discriminant: 1 (Variant2), Value: 42
      expected = [1].pack("C") + [42].pack("V")
      expect(result).to eq(expected)
    end

    it "serializes enum with string variant key" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      enum_type = described_class.new(variants: [variant1])
      program = program_double

      value = {"variant" => "Variant1", "data" => {}}
      result = enum_type.serialize(value, program: program)

      expect(result).to eq([0].pack("C"))
    end

    it "raises ArgumentError for invalid variant name" do
      variant1 = Anchor::Idl::VariantDefinition.new(name: "Variant1", fields: [])
      enum_type = described_class.new(variants: [variant1])
      program = program_double

      value = {variant: "InvalidVariant", data: {}}

      expect {
        enum_type.serialize(value, program: program)
      }.to raise_error(ArgumentError, /Invalid enum variant/)
    end
  end
end
