# frozen_string_literal: true

RSpec.describe Anchor::Idl::VecTypeDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe "#deserialize" do
    it "deserializes a vector of u8 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      vec_type = described_class.new(type: element_type)
      program = program_double

      # Length: 3, Elements: [10, 20, 30]
      data = [3].pack("V") + [10, 20, 30].pack("C*")

      result, offset = vec_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([10, 20, 30])
      expect(offset).to eq(7)
    end

    it "deserializes an empty vector" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      vec_type = described_class.new(type: element_type)
      program = program_double

      data = [0].pack("V")

      result, offset = vec_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([])
      expect(offset).to eq(4)
    end

    it "deserializes a vector of u32 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      vec_type = described_class.new(type: element_type)
      program = program_double

      # Length: 2, Elements: [100, 200]
      data = [2].pack("V") + [100, 200].pack("V*")

      result, offset = vec_type.deserialize(data, offset: 0, program: program)

      expect(result).to eq([100, 200])
      expect(offset).to eq(12)
    end
  end

  describe "#serialize" do
    it "serializes a vector of u8 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      vec_type = described_class.new(type: element_type)
      program = program_double

      value = [10, 20, 30]
      result = vec_type.serialize(value, program: program)

      # Length: 3, Elements: [10, 20, 30]
      expected = [3].pack("V") + [10, 20, 30].pack("C*")
      expect(result).to eq(expected)
    end

    it "serializes an empty vector" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u8)
      vec_type = described_class.new(type: element_type)
      program = program_double

      result = vec_type.serialize([], program: program)

      expect(result).to eq([0].pack("V"))
    end

    it "serializes a vector of u32 values" do
      element_type = Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
      vec_type = described_class.new(type: element_type)
      program = program_double

      value = [100, 200]
      result = vec_type.serialize(value, program: program)

      # Length: 2, Elements: [100, 200]
      expected = [2].pack("V") + [100, 200].pack("V*")
      expect(result).to eq(expected)
    end
  end
end
