# frozen_string_literal: true

RSpec.describe Anchor::Idl::VariantDefinition do
  describe ".from_data" do
    it "creates a variant definition from hash data" do
      data = {
        "name" => "Success",
        "fields" => [
          {
            "name" => "value",
            "type" => "u32"
          }
        ]
      }

      variant = described_class.from_data(data)

      expect(variant).to be_a(described_class)
      expect(variant.name).to eq("Success")
      expect(variant.fields.length).to eq(1)
      expect(variant.fields[0].name).to eq("value")
    end

    it "creates a variant without fields" do
      data = {
        "name" => "Empty"
      }

      variant = described_class.from_data(data)

      expect(variant).to be_a(described_class)
      expect(variant.name).to eq("Empty")
      expect(variant.fields).to eq([])
    end

    it "handles empty fields array" do
      data = {
        "name" => "NoFields",
        "fields" => []
      }

      variant = described_class.from_data(data)

      expect(variant.name).to eq("NoFields")
      expect(variant.fields).to eq([])
    end
  end
end
