# frozen_string_literal: true

RSpec.describe Anchor::Idl::InstructionDefinition do
  def program_double
    instance_double(Anchor::Idl::ProgramDefinition)
  end

  describe ".from_data" do
    it "creates an instruction definition from hash data" do
      data = {
        "name" => "transfer",
        "discriminator" => [1, 2, 3, 4, 5, 6, 7, 8],
        "accounts" => [
          {
            "name" => "from"
          }
        ],
        "args" => [
          {
            "name" => "amount",
            "type" => "u64"
          }
        ]
      }

      instruction = described_class.from_data(data)

      expect(instruction).to be_a(described_class)
      expect(instruction).to have_attributes(
        name: "transfer",
        discriminator: [1, 2, 3, 4, 5, 6, 7, 8]
      )
      expect(instruction.accounts.length).to eq(1)
      expect(instruction.accounts[0].name).to eq("from")
      expect(instruction.args.length).to eq(1)
      expect(instruction.args[0].name).to eq("amount")
    end

    it "creates an instruction with empty accounts and args" do
      data = {
        "name" => "initialize",
        "discriminator" => [0, 0, 0, 0, 0, 0, 0, 0],
        "accounts" => [],
        "args" => []
      }

      instruction = described_class.from_data(data)

      expect(instruction.accounts).to eq([])
      expect(instruction.args).to eq([])
    end
  end

  describe "#matches_discriminator?" do
    it "returns true when discriminator matches" do
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: []
      )
      data = discriminator.pack("C*") + "additional data"
      expect(instruction.matches_discriminator?(data)).to eq(true)
    end

    it "returns false when discriminator does not match" do
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: []
      )
      data = [1, 2, 3, 4, 5, 6, 7, 8].pack("C*") + "additional data"
      expect(instruction.matches_discriminator?(data)).to eq(false)
    end

    it "handles data shorter than 8 bytes" do
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: []
      )
      data = [1, 2, 3].pack("C*")
      expect(instruction.matches_discriminator?(data)).to eq(false)
    end
  end

  describe "#deserialize" do
    it "deserializes instruction with matching discriminator" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      accounts = [
        Anchor::Idl::InstructionAccountDefinition.new(name: "authority"),
        Anchor::Idl::InstructionAccountDefinition.new(name: "account")
      ]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u64)
        )
      ]
      instruction = described_class.new(
        name: "transfer",
        discriminator: discriminator,
        accounts: accounts,
        args: args
      )
      account_addresses = ["addr1", "addr2"]
      args_data = [1000].pack("Q<")
      data = discriminator.pack("C*") + args_data

      result = instruction.deserialize(data, account_addresses, program: program)

      expect(result).to be_a(Anchor::Idl::InstructionDefinition::DeserializedInstruction)
      expect(result).to have_attributes(
        args: {amount: 1000},
        accounts: {authority: "addr1", account: "addr2"}
      )
    end

    it "handles instruction with no args" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      accounts = [
        Anchor::Idl::InstructionAccountDefinition.new(name: "authority"),
        Anchor::Idl::InstructionAccountDefinition.new(name: "account")
      ]
      instruction_no_args = described_class.new(
        name: "initialize",
        discriminator: discriminator,
        accounts: accounts,
        args: []
      )
      data = discriminator.pack("C*")
      account_addresses = ["addr1", "addr2"]

      result = instruction_no_args.deserialize(data, account_addresses, program: program)

      expect(result).to have_attributes(
        args: {},
        accounts: {authority: "addr1", account: "addr2"}
      )
    end

    it "handles instruction with no accounts" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u64)
        )
      ]
      instruction_no_accounts = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: args
      )
      data = discriminator.pack("C*") + [500].pack("Q<")

      result = instruction_no_accounts.deserialize(data, [], program: program)

      expect(result).to have_attributes(
        args: {amount: 500},
        accounts: {}
      )
    end

    it "raises ArgumentError when discriminator does not match" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      accounts = [
        Anchor::Idl::InstructionAccountDefinition.new(name: "authority"),
        Anchor::Idl::InstructionAccountDefinition.new(name: "account")
      ]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u64)
        )
      ]
      instruction = described_class.new(
        name: "transfer",
        discriminator: discriminator,
        accounts: accounts,
        args: args
      )
      wrong_discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      data = wrong_discriminator.pack("C*") + [1000].pack("Q<")
      account_addresses = ["addr1"]

      expect {
        instruction.deserialize(data, account_addresses, program: program)
      }.to raise_error(ArgumentError, /Instruction discriminator does not match/)
    end

    it "handles multiple args" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      multi_args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
        ),
        Anchor::Idl::InstructionArgDefinition.new(
          name: "recipient",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :pubkey)
        )
      ]
      instruction_multi = described_class.new(
        name: "transfer",
        discriminator: discriminator,
        accounts: [],
        args: multi_args
      )

      recipient_bytes = "a" * 32
      args_data = [100].pack("V") + recipient_bytes
      data = discriminator.pack("C*") + args_data

      result = instruction_multi.deserialize(data, [], program: program)

      expect(result.args[:amount]).to eq(100)
      expect(result.args[:recipient]).to be_a(String) # Base58 encoded
    end
  end

  describe "#serialize" do
    it "serializes instruction with matching args" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u64)
        )
      ]
      instruction = described_class.new(
        name: "transfer",
        discriminator: discriminator,
        accounts: [],
        args: args
      )

      args_hash = {amount: 1000}
      result = instruction.serialize(args: args_hash, program: program)

      expected = discriminator.pack("C*") + [1000].pack("Q<")
      expect(result).to eq(expected)
    end

    it "serializes instruction with string keys in args hash" do
      program = program_double
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
        )
      ]
      instruction = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: args
      )

      args_hash = {"amount" => 42}
      result = instruction.serialize(args: args_hash, program: program)

      expected = discriminator.pack("C*") + [42].pack("V")
      expect(result).to eq(expected)
    end

    it "handles instruction with no args" do
      program = program_double
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction_no_args = described_class.new(
        name: "initialize",
        discriminator: discriminator,
        accounts: [],
        args: []
      )

      result = instruction_no_args.serialize(args: {}, program: program)

      expect(result).to eq(discriminator.pack("C*"))
    end

    it "serializes instruction with multiple args" do
      program = program_double
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      args = [
        Anchor::Idl::InstructionArgDefinition.new(
          name: "amount",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :u32)
        ),
        Anchor::Idl::InstructionArgDefinition.new(
          name: "flag",
          type: Anchor::Idl::ScalarTypeDefinition.new(type: :bool)
        )
      ]
      instruction = described_class.new(
        name: "test",
        discriminator: discriminator,
        accounts: [],
        args: args
      )

      args_hash = {amount: 100, flag: true}
      result = instruction.serialize(args: args_hash, program: program)

      expected = discriminator.pack("C*") + [100].pack("V") + [1].pack("C")
      expect(result).to eq(expected)
    end
  end
end
