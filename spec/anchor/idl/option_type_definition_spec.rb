# frozen_string_literal: true

RSpec.describe Anchor::Idl::OptionTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe "#deserialize" do
    it "deserializes None (null) value" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      option_type = described_class.new(type: element_type)
      program = program_double

      # Flag: 0 (None)
      data = [0].pack("C")

      result, offset = option_type.deserialize(data, offset: 0, program: program)

      expect(result).to be_nil
      expect(offset).to eq(1)
    end

    it "deserializes Some value" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      option_type = described_class.new(type: element_type)
      program = program_double

      # Flag: 1 (Some), Value: 42
      data = [1].pack("C") + [42].pack("V")

      result, offset = option_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq(42)
      expect(offset).to eq(5)
    end
  end

  describe "#serialize" do
    it "serializes None (null) value" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      option_type = described_class.new(type: element_type)
      program = program_double

      result = option_type.serialize(nil, program: program)

      # Flag: 0 (None)
      expect(result).to eq([0].pack("C"))
    end

    it "serializes Some value" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      option_type = described_class.new(type: element_type)
      program = program_double

      result = option_type.serialize(42, program: program)

      # Flag: 1 (Some), Value: 42
      expected = [1].pack("C") + [42].pack("V")
      expect(result).to eq(expected)
    end
  end
end
