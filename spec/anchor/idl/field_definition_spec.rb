# frozen_string_literal: true

RSpec.describe Anchor::Idl::FieldDefinition do
  describe ".from_data" do
    it "creates a field definition from hash data" do
      data = {
        "name" => "age",
        "type" => "u8"
      }

      field = described_class.from_data(data)

      expect(field).to be_a(described_class)
      expect(field.name).to eq("age")
      expect(field.type).to be_a(Anchor::Idl::ScalarTypeDefinition)
      expect(field.type.type).to eq(:u8)
    end

    it "creates a field definition with nested type" do
      data = {
        "name" => "scores",
        "type" => {
          "vec" => "u32"
        }
      }

      field = described_class.from_data(data)

      expect(field).to be_a(described_class)
      expect(field.name).to eq("scores")
      expect(field.type).to be_a(Anchor::Idl::VecTypeDefinition)
    end
  end
end
