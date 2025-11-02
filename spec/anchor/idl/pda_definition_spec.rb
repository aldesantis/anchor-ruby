# frozen_string_literal: true

RSpec.describe Anchor::Idl::PdaDefinition do
  describe ".from_data" do
    it "creates a PDA definition with seeds only" do
      data = {
        "seeds" => [
          {
            "kind" => "const",
            "value" => "seed1"
          },
          {
            "kind" => "arg",
            "path" => "account.id"
          }
        ]
      }

      pda = described_class.from_data(data)

      expect(pda).to be_a(described_class)
      expect(pda.seeds.length).to eq(2)
      expect(pda.seeds[0].kind).to eq("const")
      expect(pda.seeds[0].value).to eq("seed1")
      expect(pda.seeds[1].kind).to eq("arg")
      expect(pda.seeds[1].path).to eq("account.id")
      expect(pda.program).to be_nil
    end

    it "creates a PDA definition with seeds and program" do
      data = {
        "seeds" => [
          {
            "kind" => "const",
            "value" => "seed"
          }
        ],
        "program" => {
          "kind" => "program",
          "value" => "ProgramAddress"
        }
      }

      pda = described_class.from_data(data)

      expect(pda).to be_a(described_class)
      expect(pda.seeds.length).to eq(1)
      expect(pda.program).to be_a(Anchor::Idl::ProgramReferenceDefinition)
      expect(pda.program.kind).to eq("program")
      expect(pda.program.value).to eq("ProgramAddress")
    end

    it "creates a PDA definition with empty seeds" do
      data = {
        "seeds" => []
      }

      pda = described_class.from_data(data)

      expect(pda).to have_attributes(
        seeds: [],
        program: nil
      )
    end
  end

  describe "#as_json" do
    it "returns hash with seeds and program" do
      seeds = [
        Anchor::Idl::SeedDefinition.new(kind: "const", value: "seed1"),
        Anchor::Idl::SeedDefinition.new(kind: "arg", path: "path1")
      ]
      program = Anchor::Idl::ProgramReferenceDefinition.new(kind: "program", value: "addr")
      pda = described_class.new(seeds: seeds, program: program)

      result = pda.as_json

      expect(result[:seeds]).to be_an(Array)
      expect(result[:seeds].length).to eq(2)
      expect(result[:seeds][0]).to eq({kind: "const", value: "seed1", path: nil})
      expect(result[:seeds][1]).to eq({kind: "arg", value: nil, path: "path1"})
      expect(result[:program]).to eq({kind: "program", value: "addr", path: nil})
    end

    it "returns hash with nil program when not set" do
      seeds = [Anchor::Idl::SeedDefinition.new(kind: "const")]
      pda = described_class.new(seeds: seeds)

      result = pda.as_json

      expect(result[:seeds]).to be_an(Array)
      expect(result[:program]).to be_nil
    end
  end
end
