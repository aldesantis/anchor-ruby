module Anchor
  module Idl
    class OptionTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          new(type: TypeDefinition.from_data(data))
        end
      end

      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def deserialize(data, offset:, program:)
        has_value, offset = ScalarTypeDefinition.new(type: :u8).deserialize(
          data,
          offset: offset,
          program: program
        )

        return [nil, offset] if has_value == 0

        type.deserialize(
          data,
          offset: offset,
          program: program
        )
      end

      def serialize(value, program:)
        if value.nil?
          ScalarTypeDefinition.new(type: :u8).serialize(0, program: program)
        else
          ScalarTypeDefinition.new(type: :u8).serialize(1, program: program) +
            type.serialize(value, program: program)
        end
      end
    end
  end
end
