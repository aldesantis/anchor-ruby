# frozen_string_literal: true

RSpec.describe Anchor::Idl::SeedDefinition do
  describe ".from_data" do
    it "creates a seed definition with kind only" do
      data = {
        "kind" => "const"
      }

      seed = described_class.from_data(data)

      expect(seed).to be_a(described_class)
      expect(seed).to have_attributes(
        kind: "const",
        value: nil,
        path: nil
      )
    end

    it "creates a seed definition with kind and value" do
      data = {
        "kind" => "const",
        "value" => "seed_value"
      }

      seed = described_class.from_data(data)

      expect(seed).to have_attributes(
        kind: "const",
        value: "seed_value",
        path: nil
      )
    end

    it "creates a seed definition with kind and path" do
      data = {
        "kind" => "arg",
        "path" => "account.owner"
      }

      seed = described_class.from_data(data)

      expect(seed).to have_attributes(
        kind: "arg",
        value: nil,
        path: "account.owner"
      )
    end

    it "creates a seed definition with all fields" do
      data = {
        "kind" => "account",
        "value" => "some_value",
        "path" => "some.path"
      }

      seed = described_class.from_data(data)

      expect(seed).to have_attributes(
        kind: "account",
        value: "some_value",
        path: "some.path"
      )
    end
  end

  describe "#as_json" do
    it "returns hash with all fields" do
      seed = described_class.new(kind: "const", value: "seed", path: "path")

      result = seed.as_json

      expect(result).to eq({
        kind: "const",
        value: "seed",
        path: "path"
      })
    end

    it "includes nil values in JSON" do
      seed = described_class.new(kind: "const")

      result = seed.as_json

      expect(result).to eq({
        kind: "const",
        value: nil,
        path: nil
      })
    end
  end
end
