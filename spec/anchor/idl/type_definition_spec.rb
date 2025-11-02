# frozen_string_literal: true

RSpec.describe Anchor::Idl::TypeDefinition do
  describe ".from_data" do
    it "creates a scalar type from a string" do
      type = described_class.from_data("u32")
      expect(type).to be_a(Anchor::Idl::ScalarTypeDefinition)
      expect(type.type).to eq(:u32)
    end

    it "creates a struct type from hash with kind: struct" do
      data = {
        "kind" => "struct",
        "fields" => []
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::StructTypeDefinition)
    end

    it "creates an enum type from hash with kind: enum" do
      data = {
        "kind" => "enum",
        "variants" => []
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::EnumTypeDefinition)
    end

    it "creates a defined type from hash with defined key" do
      data = {
        "defined" => "MyType"
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::DefinedTypeDefinition)
      expect(type.name).to eq("MyType")
    end

    it "creates an option type from hash with option key" do
      data = {
        "option" => "u32"
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::OptionTypeDefinition)
    end

    it "creates a vec type from hash with vec key" do
      data = {
        "vec" => "u8"
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::VecTypeDefinition)
    end

    it "creates an array type from hash with array key" do
      data = {
        "array" => ["u8", 10]
      }
      type = described_class.from_data(data)
      expect(type).to be_a(Anchor::Idl::ArrayTypeDefinition)
      expect(type.length).to eq(10)
    end

    it "raises ArgumentError for unknown type definition" do
      expect {
        described_class.from_data({"unknown" => "type"})
      }.to raise_error(ArgumentError, /Unknown type definition/)
    end

    it "raises ArgumentError for nil data" do
      expect {
        described_class.from_data(nil)
      }.to raise_error(ArgumentError, /Unknown type definition/)
    end
  end

  describe "#deserialize" do
    it "raises NotImplementedError on base class" do
      type = Anchor::Idl::TypeDefinition.new
      expect {
        type.deserialize("", offset: 0, program: instance_double(Anchor::Idl::ProgramDefinition))
      }.to raise_error(NotImplementedError, /Type definitions must implement #deserialize/)
    end
  end

  describe "#serialize" do
    it "raises NotImplementedError on base class" do
      type = Anchor::Idl::TypeDefinition.new
      expect {
        type.serialize(42, program: instance_double(Anchor::Idl::ProgramDefinition))
      }.to raise_error(NotImplementedError, /Type definitions must implement #serialize/)
    end
  end
end
