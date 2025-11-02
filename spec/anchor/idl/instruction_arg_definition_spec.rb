# frozen_string_literal: true

RSpec.describe Anchor::Idl::InstructionArgDefinition do
  describe ".from_data" do
    it "creates an instruction arg definition from hash data" do
      data = {
        "name" => "amount",
        "type" => "u64"
      }

      arg = described_class.from_data(data)

      expect(arg).to be_a(described_class)
      expect(arg.name).to eq("amount")
      expect(arg.type).to be_a(Anchor::Idl::ScalarTypeDefinition)
      expect(arg.type.type).to eq(:u64)
    end

    it "creates an instruction arg with nested type" do
      data = {
        "name" => "items",
        "type" => {
          "vec" => "string"
        }
      }

      arg = described_class.from_data(data)

      expect(arg).to be_a(described_class)
      expect(arg.name).to eq("items")
      expect(arg.type).to be_a(Anchor::Idl::VecTypeDefinition)
    end
  end
end
