module Anchor
  module Idl
    class InstructionDefinition
      attr_reader :name
      attr_reader :discriminator
      attr_reader :accounts
      attr_reader :args

      class << self
        def from_data(data)
          new(
            name: data.fetch("name"),
            discriminator: data.fetch("discriminator"),
            accounts: data.fetch("accounts").map { |account_data| InstructionAccountDefinition.from_data(account_data) },
            args: data.fetch("args").map { |arg_data| InstructionArgDefinition.from_data(arg_data) }
          )
        end
      end

      class DeserializedInstruction
        attr_reader :args
        attr_reader :accounts

        def initialize(args:, accounts:)
          @args = args
          @accounts = accounts
        end
      end

      def initialize(name:, discriminator:, accounts:, args:)
        @name = name
        @discriminator = discriminator
        @accounts = accounts
        @args = args
      end

      def matches_discriminator?(data)
        extract_discriminator(data) == discriminator
      end

      def deserialize(data, accounts, program:)
        unless matches_discriminator?(data)
          raise ArgumentError, "Instruction discriminator does not match for '#{name}'. Expected #{discriminator.inspect}, got #{extract_discriminator(data).inspect}"
        end

        args_data = data[8..] || ""

        DeserializedInstruction.new(
          args: map_args(args_data, program),
          accounts: map_accounts(accounts)
        )
      end

      def serialize(args:, program:)
        result = discriminator.pack("C*")

        self.args.each do |arg_definition|
          arg_name = arg_definition.name
          arg_value = args[arg_name.to_sym] || args[arg_name]
          result += arg_definition.type.serialize(arg_value, program: program)
        end

        result
      end

      private

      def map_args(args_data, program)
        offset = 0

        args.map do |arg_definition|
          value, offset = arg_definition.type.deserialize(
            args_data,
            offset: offset,
            program: program
          )

          [arg_definition.name.to_sym, value]
        end.to_h
      end

      def map_accounts(account_addresses)
        accounts.map.with_index do |account_definition, index|
          address = account_addresses[index]

          [account_definition.name.to_sym, address]
        end.to_h
      end

      def extract_discriminator(data)
        data[0, 8].unpack("C*")
      end
    end
  end
end
