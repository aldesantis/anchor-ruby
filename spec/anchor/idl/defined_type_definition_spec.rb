# frozen_string_literal: true

RSpec.describe Anchor::Idl::DefinedTypeDefinition do
  describe ".from_data" do
    it "creates a defined type from string name" do
      data = "MyCustomType"
      type = described_class.from_data(data)

      expect(type).to be_a(described_class)
      expect(type.name).to eq("MyCustomType")
    end
  end

  describe "#deserialize" do
    it "delegates to the program's type definition" do
      program = instance_double(Anchor::Idl::ProgramDefinition)
      nested_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      type_def = instance_double(Anchor::Idl::FieldDefinition, type: nested_type)

      allow(program).to receive(:find_type!).with("MyType").and_return(type_def)
      allow(nested_type).to receive(:deserialize).and_return([42, 4])

      defined_type = described_class.new(name: "MyType")
      data = [42].pack("V")

      result, offset = defined_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq(42)
      expect(offset).to eq(4)
      expect(program).to have_received(:find_type!).with("MyType")
      expect(nested_type).to have_received(:deserialize).with(data, offset: 0, program: program)
    end

    it "raises error when type not found in program" do
      program = instance_double(Anchor::Idl::ProgramDefinition)
      allow(program).to receive(:find_type!).and_raise(ArgumentError, "Type MyType not found in IDL")

      defined_type = described_class.new(name: "MyType")
      data = [42].pack("V")

      expect {
        defined_type.deserialize(data, offset: 0, program: program)
      }.to raise_error(ArgumentError, /Type MyType not found/)
    end
  end

  describe "#serialize" do
    it "delegates to the program's type definition" do
      program = instance_double(Anchor::Idl::ProgramDefinition)
      nested_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      type_def = instance_double(Anchor::Idl::FieldDefinition, type: nested_type)

      allow(program).to receive(:find_type!).with("MyType").and_return(type_def)
      allow(nested_type).to receive(:serialize).and_return([42].pack("V"))

      defined_type = described_class.new(name: "MyType")
      result = defined_type.serialize(42, program: program)

      expect(result).to eq([42].pack("V"))
      expect(program).to have_received(:find_type!).with("MyType")
      expect(nested_type).to have_received(:serialize).with(42, program: program)
    end

    it "raises error when type not found in program" do
      program = instance_double(Anchor::Idl::ProgramDefinition)
      allow(program).to receive(:find_type!).and_raise(ArgumentError, "Type MyType not found in IDL")

      defined_type = described_class.new(name: "MyType")

      expect {
        defined_type.serialize(42, program: program)
      }.to raise_error(ArgumentError, /Type MyType not found/)
    end
  end
end
