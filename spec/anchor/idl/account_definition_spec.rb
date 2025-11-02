# frozen_string_literal: true

RSpec.describe Anchor::Idl::AccountDefinition do
  describe ".from_data" do
    it "creates an account definition from hash data" do
      data = {
        "name" => "TokenAccount",
        "discriminator" => [1, 2, 3, 4, 5, 6, 7, 8]
      }

      account = described_class.from_data(data)

      expect(account).to be_a(described_class)
      expect(account.name).to eq("TokenAccount")
      expect(account.discriminator).to eq([1, 2, 3, 4, 5, 6, 7, 8])
    end
  end

  describe "#valid_discriminator?" do
    it "returns true when discriminator matches" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = discriminator.pack("C*") + "additional data"
      expect(account.valid_discriminator?(account_data)).to eq(true)
    end

    it "returns false when discriminator does not match" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = [9, 8, 7, 6, 5, 4, 3, 2].pack("C*") + "additional data"
      expect(account.valid_discriminator?(account_data)).to eq(false)
    end

    it "handles data shorter than 8 bytes" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = [1, 2, 3].pack("C*")
      expect(account.valid_discriminator?(account_data)).to eq(false)
    end

    it "handles exactly 8 bytes of data" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = discriminator.pack("C*")
      expect(account.valid_discriminator?(account_data)).to eq(true)
    end
  end

  describe "#validate_discriminator!" do
    it "does not raise error when discriminator is valid" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = discriminator.pack("C*") + "additional data"
      expect {
        account.validate_discriminator!(account_data)
      }.not_to raise_error
    end

    it "raises InvalidDiscriminatorError when discriminator is invalid" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = [9, 8, 7, 6, 5, 4, 3, 2].pack("C*") + "additional data"
      expect {
        account.validate_discriminator!(account_data)
      }.to raise_error(Anchor::Idl::AccountDefinition::InvalidDiscriminatorError, /Invalid account discriminator/)
    end

    it "raises InvalidDiscriminatorError when data is too short" do
      discriminator = [1, 2, 3, 4, 5, 6, 7, 8]
      account = described_class.new(name: "TestAccount", discriminator: discriminator)
      account_data = [1, 2, 3].pack("C*")
      expect {
        account.validate_discriminator!(account_data)
      }.to raise_error(Anchor::Idl::AccountDefinition::InvalidDiscriminatorError)
    end
  end
end
