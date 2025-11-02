module Anchor
  module Idl
    class AccountDefinition
      attr_reader :name
      attr_reader :discriminator

      class << self
        def from_data(data)
          new(
            name: data.fetch("name"),
            discriminator: data.fetch("discriminator")
          )
        end
      end

      class InvalidDiscriminatorError < StandardError; end

      def initialize(name:, discriminator:)
        @name = name
        @discriminator = discriminator
      end

      def valid_discriminator?(account_data)
        actual_discriminator = account_data[0, 8].unpack("C*")

        discriminator == actual_discriminator
      end

      def validate_discriminator!(account_data)
        return if valid_discriminator?(account_data)

        raise InvalidDiscriminatorError, "Invalid account discriminator"
      end
    end
  end
end
