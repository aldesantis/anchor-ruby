# frozen_string_literal: true

RSpec.describe Anchor::Idl::ProgramDefinition do
  def idl_data
    {
      "address" => "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
      "metadata" => {"name" => "Test Program"},
      "instructions" => [
        {
          "name" => "initialize",
          "discriminator" => [175, 175, 109, 31, 13, 152, 155, 237],
          "accounts" => [],
          "args" => []
        }
      ],
      "accounts" => [
        {
          "name" => "TestAccount",
          "discriminator" => [1, 2, 3, 4, 5, 6, 7, 8]
        }
      ],
      "errors" => [
        {
          "code" => 6000,
          "name" => "TestError",
          "msg" => "This is a test error"
        }
      ],
      "types" => [
        {
          "name" => "TestType",
          "type" => "u32"
        }
      ]
    }
  end

  def test_program
    described_class.from_data(idl_data)
  end

  describe ".from_data" do
    it "creates a program definition from hash data" do
      program = described_class.from_data(idl_data)

      expect(program.address).to eq("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
      expect(program.metadata["name"]).to eq("Test Program")
      expect(program.instructions.length).to eq(1)
      expect(program.accounts.length).to eq(1)
      expect(program.errors.length).to eq(1)
      expect(program.types.length).to eq(1)
    end
  end

  describe ".from_file" do
    it "creates a program definition from a JSON file" do
      file_path = "/tmp/test_idl.json"
      File.write(file_path, JSON.generate(idl_data))
      begin
        program = described_class.from_file(file_path)
        expect(program.address).to eq("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
      ensure
        File.delete(file_path) if File.exist?(file_path)
      end
    end
  end

  describe "#find_instruction" do
    it "finds an instruction by name" do
      program = test_program
      instruction = program.find_instruction("initialize")
      expect(instruction).not_to be_nil
      expect(instruction.name).to eq("initialize")
    end

    it "returns nil for non-existent instruction" do
      program = test_program
      instruction = program.find_instruction("nonexistent")
      expect(instruction).to be_nil
    end
  end

  describe "#find_instruction!" do
    it "finds an instruction by name" do
      program = test_program
      instruction = program.find_instruction!("initialize")
      expect(instruction.name).to eq("initialize")
    end

    it "raises error for non-existent instruction" do
      program = test_program
      expect {
        program.find_instruction!("nonexistent")
      }.to raise_error(ArgumentError, /Instruction nonexistent not found/)
    end
  end

  describe "#find_account" do
    it "finds an account by name" do
      program = test_program
      account = program.find_account("TestAccount")
      expect(account).not_to be_nil
      expect(account.name).to eq("TestAccount")
    end

    it "returns nil for non-existent account" do
      program = test_program
      account = program.find_account("nonexistent")
      expect(account).to be_nil
    end
  end

  describe "#find_account!" do
    it "finds an account by name" do
      program = test_program
      account = program.find_account!("TestAccount")
      expect(account.name).to eq("TestAccount")
    end

    it "raises error for non-existent account" do
      program = test_program
      expect {
        program.find_account!("nonexistent")
      }.to raise_error(ArgumentError, /Account nonexistent not found/)
    end
  end

  describe "#find_instruction_by_discriminator" do
    it "finds an instruction by discriminator" do
      program = test_program
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction = program.find_instruction_by_discriminator(discriminator)
      expect(instruction).not_to be_nil
      expect(instruction.name).to eq("initialize")
    end

    it "returns nil for non-existent discriminator" do
      program = test_program
      instruction = program.find_instruction_by_discriminator([1, 2, 3, 4, 5, 6, 7, 8])
      expect(instruction).to be_nil
    end
  end

  describe "#find_instruction_by_discriminator!" do
    it "finds an instruction by discriminator" do
      program = test_program
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      instruction = program.find_instruction_by_discriminator!(discriminator)
      expect(instruction.name).to eq("initialize")
    end

    it "raises error for non-existent discriminator" do
      program = test_program
      expect {
        program.find_instruction_by_discriminator!([1, 2, 3, 4, 5, 6, 7, 8])
      }.to raise_error(ArgumentError, /Instruction with discriminator/)
    end
  end

  describe "#find_instruction_from_data" do
    it "finds an instruction from binary data" do
      program = test_program
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      data = discriminator.pack("C*") + "additional data"
      instruction = program.find_instruction_from_data(data)
      expect(instruction).not_to be_nil
      expect(instruction.name).to eq("initialize")
    end

    it "returns nil for non-existent discriminator" do
      program = test_program
      data = [1, 2, 3, 4, 5, 6, 7, 8].pack("C*")
      instruction = program.find_instruction_from_data(data)
      expect(instruction).to be_nil
    end

    it "raises error if data is too short" do
      program = test_program
      data = [1, 2, 3].pack("C*")
      expect {
        program.find_instruction_from_data(data)
      }.to raise_error(ArgumentError, /too short/)
    end
  end

  describe "#find_instruction_from_data!" do
    it "finds an instruction from binary data" do
      program = test_program
      discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
      data = discriminator.pack("C*") + "additional data"
      instruction = program.find_instruction_from_data!(data)
      expect(instruction.name).to eq("initialize")
    end

    it "raises error for non-existent discriminator" do
      program = test_program
      data = [1, 2, 3, 4, 5, 6, 7, 8].pack("C*")
      expect {
        program.find_instruction_from_data!(data)
      }.to raise_error(ArgumentError, /Instruction with discriminator/)
    end

    it "raises error if data is too short" do
      program = test_program
      data = [1, 2, 3].pack("C*")
      expect {
        program.find_instruction_from_data!(data)
      }.to raise_error(ArgumentError, /too short/)
    end
  end

  describe "#find_account_by_discriminator" do
    it "finds an account by discriminator" do
      program = test_program
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = program.find_account_by_discriminator(discriminator)
      expect(account).not_to be_nil
      expect(account.name).to eq("TestAccount")
    end

    it "returns nil for non-existent discriminator" do
      program = test_program
      account = program.find_account_by_discriminator([175, 175, 109, 31, 13, 152, 155, 237])
      expect(account).to be_nil
    end
  end

  describe "#find_account_by_discriminator!" do
    it "finds an account by discriminator" do
      program = test_program
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = program.find_account_by_discriminator!(discriminator)
      expect(account.name).to eq("TestAccount")
    end

    it "raises error for non-existent discriminator" do
      program = test_program
      expect {
        program.find_account_by_discriminator!([175, 175, 109, 31, 13, 152, 155, 237])
      }.to raise_error(ArgumentError, /Account with discriminator/)
    end
  end

  describe "#find_account_from_data" do
    it "finds an account from binary data" do
      program = test_program
      data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].pack("C*")
      account = program.find_account_from_data(data)
      expect(account).not_to be_nil
      expect(account.name).to eq("TestAccount")
    end

    it "returns nil for non-existent discriminator" do
      program = test_program
      data = [175, 175, 109, 31, 13, 152, 155, 237].pack("C*")
      account = program.find_account_from_data(data)
      expect(account).to be_nil
    end

    it "raises error if data is too short" do
      program = test_program
      data = [1, 2, 3].pack("C*")
      expect {
        program.find_account_from_data(data)
      }.to raise_error(ArgumentError, /too short/)
    end
  end

  describe "#find_account_from_data!" do
    it "finds an account from binary data" do
      program = test_program
      data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].pack("C*")
      account = program.find_account_from_data!(data)
      expect(account.name).to eq("TestAccount")
    end

    it "raises error for non-existent discriminator" do
      program = test_program
      data = [175, 175, 109, 31, 13, 152, 155, 237].pack("C*")
      expect {
        program.find_account_from_data!(data)
      }.to raise_error(ArgumentError, /Account with discriminator/)
    end

    it "raises error if data is too short" do
      program = test_program
      data = [1, 2, 3].pack("C*")
      expect {
        program.find_account_from_data!(data)
      }.to raise_error(ArgumentError, /too short/)
    end
  end

  describe "#find_type" do
    it "finds a type by name" do
      program = test_program
      type = program.find_type("TestType")
      expect(type).not_to be_nil
      expect(type.name).to eq("TestType")
    end

    it "returns nil for non-existent type" do
      program = test_program
      type = program.find_type("nonexistent")
      expect(type).to be_nil
    end
  end

  describe "#find_type!" do
    it "finds a type by name" do
      program = test_program
      type = program.find_type!("TestType")
      expect(type.name).to eq("TestType")
    end

    it "raises error for non-existent type" do
      program = test_program
      expect {
        program.find_type!("nonexistent")
      }.to raise_error(ArgumentError, /Type nonexistent not found/)
    end
  end

  describe "#find_error" do
    it "finds an error by name" do
      program = test_program
      error = program.find_error("TestError")
      expect(error).not_to be_nil
      expect(error.name).to eq("TestError")
      expect(error.code).to eq(6000)
    end

    it "returns nil for non-existent error" do
      program = test_program
      error = program.find_error("nonexistent")
      expect(error).to be_nil
    end
  end

  describe "#find_error!" do
    it "finds an error by name" do
      program = test_program
      error = program.find_error!("TestError")
      expect(error.name).to eq("TestError")
      expect(error.code).to eq(6000)
    end

    it "raises error for non-existent error" do
      program = test_program
      expect {
        program.find_error!("nonexistent")
      }.to raise_error(ArgumentError, /Error nonexistent not found/)
    end
  end
end
