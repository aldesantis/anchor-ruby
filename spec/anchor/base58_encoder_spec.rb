# frozen_string_literal: true

RSpec.describe Anchor::Base58Encoder do
  describe "#base58_from_data" do
    it "encodes binary data to Base58" do
      encoder = described_class.new
      data = "Hello World"
      encoded = encoder.base58_from_data(data)
      expect(encoded).to eq("JxF12TrwUP45BMd")
    end

    it "handles empty data" do
      encoder = described_class.new
      expect(encoder.base58_from_data("")).to eq("")
    end

    it "handles leading zeros" do
      encoder = described_class.new
      data = "\x00\x00abc"
      encoded = encoder.base58_from_data(data)
      expect(encoded).to start_with("11")
    end
  end

  describe "#data_from_base58" do
    it "decodes Base58 to binary data" do
      encoder = described_class.new
      encoded = "JxF12TrwUP45BMd"
      decoded = encoder.data_from_base58(encoded)
      expect(decoded).to eq("Hello World")
    end

    it "handles empty string" do
      encoder = described_class.new
      expect(encoder.data_from_base58("")).to eq("")
    end

    it "raises error for invalid Base58 characters" do
      encoder = described_class.new
      expect {
        encoder.data_from_base58("Invalid0Character")
      }.to raise_error(Anchor::Base58Encoder::FormatError, /Invalid Base58 character/)
    end
  end

  describe "#base58check_from_data" do
    it "encodes data with checksum" do
      encoder = described_class.new
      data = "test"
      encoded = encoder.base58check_from_data(data)
      expect(encoded).to be_a(String)
      expect(encoded.length).to be > 0
    end
  end

  describe "#data_from_base58check" do
    it "decodes data and validates checksum" do
      encoder = described_class.new
      data = "test"
      encoded = encoder.base58check_from_data(data)
      decoded = encoder.data_from_base58check(encoded)
      expect(decoded).to eq(data)
    end

    it "raises error for invalid checksum" do
      encoder = described_class.new
      encoded = encoder.base58check_from_data("test")
      # Corrupt the encoded string
      corrupted = encoded[0..-2] + ((encoded[-1] == "a") ? "b" : "a")

      expect {
        encoder.data_from_base58check(corrupted)
      }.to raise_error(Anchor::Base58Encoder::FormatError, /checksum invalid/)
    end

    it "raises error for too short string" do
      encoder = described_class.new
      expect {
        encoder.data_from_base58check("abc")
      }.to raise_error(Anchor::Base58Encoder::FormatError, /too short/)
    end
  end

  describe "round-trip encoding" do
    it "preserves data through encode-decode cycle" do
      encoder = described_class.new
      original_data = "The quick brown fox jumps over the lazy dog"
      encoded = encoder.base58_from_data(original_data)
      decoded = encoder.data_from_base58(encoded)
      expect(decoded).to eq(original_data)
    end

    it "preserves binary data" do
      encoder = described_class.new
      original_data = [0, 1, 2, 3, 255, 254, 253].pack("C*")
      encoded = encoder.base58_from_data(original_data)
      decoded = encoder.data_from_base58(encoded)
      expect(decoded).to eq(original_data)
    end
  end
end
