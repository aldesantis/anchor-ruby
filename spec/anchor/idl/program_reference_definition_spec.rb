# frozen_string_literal: true

RSpec.describe Anchor::Idl::ProgramReferenceDefinition do
  describe ".from_data" do
    it "creates a program reference with kind only" do
      data = {
        "kind" => "program"
      }

      program_ref = described_class.from_data(data)

      expect(program_ref).to be_a(described_class)
      expect(program_ref).to have_attributes(
        kind: "program",
        value: nil,
        path: nil
      )
    end

    it "creates a program reference with kind and value" do
      data = {
        "kind" => "program",
        "value" => "ProgramAddress123"
      }

      program_ref = described_class.from_data(data)

      expect(program_ref).to have_attributes(
        kind: "program",
        value: "ProgramAddress123",
        path: nil
      )
    end

    it "creates a program reference with kind and path" do
      data = {
        "kind" => "account",
        "path" => "program.address"
      }

      program_ref = described_class.from_data(data)

      expect(program_ref).to have_attributes(
        kind: "account",
        value: nil,
        path: "program.address"
      )
    end

    it "creates a program reference with all fields" do
      data = {
        "kind" => "arg",
        "value" => "some_value",
        "path" => "some.path"
      }

      program_ref = described_class.from_data(data)

      expect(program_ref).to have_attributes(
        kind: "arg",
        value: "some_value",
        path: "some.path"
      )
    end
  end

  describe "#as_json" do
    it "returns hash with all fields" do
      program_ref = described_class.new(kind: "program", value: "addr", path: "path")

      result = program_ref.as_json

      expect(result).to eq({
        kind: "program",
        value: "addr",
        path: "path"
      })
    end

    it "includes nil values in JSON" do
      program_ref = described_class.new(kind: "program")

      result = program_ref.as_json

      expect(result).to eq({
        kind: "program",
        value: nil,
        path: nil
      })
    end
  end
end
