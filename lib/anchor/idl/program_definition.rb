module Anchor
  module Idl
    class ProgramDefinition
      attr_reader :address
      attr_reader :metadata
      attr_reader :instructions
      attr_reader :accounts
      attr_reader :errors
      attr_reader :types

      class << self
        def from_file(file_path)
          from_data(JSON.parse(File.read(file_path)))
        end

        def from_data(data)
          new(
            address: data.fetch("address"),
            metadata: data.fetch("metadata"),
            instructions: data.fetch("instructions").map { |instruction| InstructionDefinition.from_data(instruction) },
            accounts: data.fetch("accounts").map { |account| AccountDefinition.from_data(account) },
            errors: data.fetch("errors").map { |error| ErrorDefinition.from_data(error) },
            types: data.fetch("types").map { |type| FieldDefinition.from_data(type) }
          )
        end
      end

      def initialize(address:, metadata:, instructions:, accounts:, errors:, types:)
        @address = address
        @metadata = metadata
        @instructions = instructions
        @accounts = accounts
        @errors = errors
        @types = types
      end

      def find_instruction(name)
        instructions.find { |instruction| instruction.name == name }
      end

      def find_instruction!(name)
        find_instruction(name) || raise(ArgumentError, "Instruction #{name} not found in IDL")
      end

      def find_account(name)
        accounts.find { |account| account.name == name }
      end

      def find_account!(name)
        find_account(name) || raise(ArgumentError, "Account #{name} not found in IDL")
      end

      def find_error(name)
        errors.find { |error| error.name == name }
      end

      def find_error!(name)
        find_error(name) || raise(ArgumentError, "Error #{name} not found in IDL")
      end

      def find_type(name)
        types.find { |type| type.name == name }
      end

      def find_type!(name)
        find_type(name) || raise(ArgumentError, "Type #{name} not found in IDL")
      end

      def find_instruction_by_discriminator(discriminator)
        instructions.find { |instruction| instruction.discriminator == discriminator }
      end

      def find_instruction_by_discriminator!(discriminator)
        find_instruction_by_discriminator(discriminator) ||
          raise(ArgumentError, "Instruction with discriminator #{discriminator} not found in IDL")
      end

      def find_instruction_from_data(instruction_data)
        discriminator = extract_instruction_discriminator(instruction_data)
        find_instruction_by_discriminator(discriminator)
      end

      def find_instruction_from_data!(instruction_data)
        discriminator = extract_instruction_discriminator(instruction_data)
        find_instruction_by_discriminator(discriminator) || raise(ArgumentError, "Instruction with discriminator #{discriminator} not found in IDL")
      end

      def find_account_by_discriminator(discriminator)
        accounts.find { |account| account.discriminator == discriminator }
      end

      def find_account_by_discriminator!(discriminator)
        find_account_by_discriminator(discriminator) ||
          raise(ArgumentError, "Account with discriminator #{discriminator} not found in IDL")
      end

      def find_account_from_data(account_data)
        discriminator = extract_account_discriminator(account_data)
        find_account_by_discriminator(discriminator)
      end

      def find_account_from_data!(account_data)
        discriminator = extract_account_discriminator(account_data)
        find_account_by_discriminator(discriminator) || raise(ArgumentError, "Account with discriminator #{discriminator} not found in IDL")
      end

      private

      def extract_instruction_discriminator(instruction_data)
        raise ArgumentError, "Instruction data too short for discriminator" if instruction_data.length < 8

        instruction_data[0, 8].unpack("C*")
      end

      def extract_account_discriminator(account_data)
        raise ArgumentError, "Account data too short for discriminator" if account_data.length < 8

        account_data[0, 8].unpack("C*")
      end
    end
  end
end
