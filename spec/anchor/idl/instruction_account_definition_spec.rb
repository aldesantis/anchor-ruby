# frozen_string_literal: true

RSpec.describe Anchor::Idl::InstructionAccountDefinition do
  describe ".from_data" do
    it "creates an instruction account definition with minimal data" do
      data = {
        "name" => "authority"
      }

      account = described_class.from_data(data)

      expect(account).to be_a(described_class)
      expect(account).to have_attributes(
        name: "authority",
        writable: false,
        signer: false,
        optional: false,
        pda: nil,
        relations: [],
        address: nil
      )
    end

    it "creates an instruction account with all flags set" do
      data = {
        "name" => "account",
        "writable" => true,
        "signer" => true,
        "optional" => true
      }

      account = described_class.from_data(data)

      expect(account).to have_attributes(
        name: "account",
        writable: true,
        signer: true,
        optional: true
      )
    end

    it "creates an instruction account with PDA" do
      data = {
        "name" => "derived_account",
        "pda" => {
          "seeds" => [
            {
              "kind" => "const",
              "value" => "seed"
            }
          ]
        }
      }

      account = described_class.from_data(data)

      expect(account.name).to eq("derived_account")
      expect(account.pda).to be_a(Anchor::Idl::PdaDefinition)
      expect(account.pda.seeds.length).to eq(1)
    end

    it "creates an instruction account with relations" do
      data = {
        "name" => "related_account",
        "relations" => ["parent_account", "sibling_account"]
      }

      account = described_class.from_data(data)

      expect(account.relations).to eq(["parent_account", "sibling_account"])
    end

    it "creates an instruction account with address" do
      data = {
        "name" => "fixed_account",
        "address" => "FixedAddress123"
      }

      account = described_class.from_data(data)

      expect(account.address).to eq("FixedAddress123")
    end

    it "handles all optional fields together" do
      data = {
        "name" => "full_account",
        "writable" => true,
        "signer" => true,
        "optional" => true,
        "pda" => {
          "seeds" => []
        },
        "relations" => ["rel1"],
        "address" => "Address1"
      }

      account = described_class.from_data(data)

      expect(account).to have_attributes(
        writable: true,
        signer: true,
        optional: true,
        relations: ["rel1"],
        address: "Address1"
      )
      expect(account.pda).not_to be_nil
    end
  end
end
