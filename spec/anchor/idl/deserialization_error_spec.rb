# frozen_string_literal: true

RSpec.describe Anchor::Idl::DeserializationError do
  it "is a StandardError" do
    expect(described_class).to be < StandardError
  end

  it "can be raised and caught" do
    expect {
      raise described_class, "Test deserialization error"
    }.to raise_error(described_class, /Test deserialization error/)
  end

  it "can be raised with a message" do
    error = described_class.new("Need 4 bytes at offset 0, but only 2 bytes available")
    expect(error.message).to eq("Need 4 bytes at offset 0, but only 2 bytes available")
  end

  it "can be raised without a message" do
    error = described_class.new
    expect(error).to be_a(described_class)
  end
end
