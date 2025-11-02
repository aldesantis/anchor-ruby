# frozen_string_literal: true

RSpec.describe Anchor::Idl::ErrorDefinition do
  describe ".from_data" do
    it "creates an error definition from hash data" do
      data = {
        "code" => 6000,
        "name" => "InsufficientFunds",
        "msg" => "Insufficient funds for transaction"
      }

      error = described_class.from_data(data)

      expect(error).to be_a(described_class)
      expect(error).to have_attributes(
        code: 6000,
        name: "InsufficientFunds",
        msg: "Insufficient funds for transaction"
      )
    end
  end
end
