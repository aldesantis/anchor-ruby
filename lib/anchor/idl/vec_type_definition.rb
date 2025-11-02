module Anchor
  module Idl
    class VecTypeDefinition < TypeDefinition
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
        length, offset = ScalarTypeDefinition.new(type: :u32).deserialize(
          data,
          offset: offset,
          program: program
        )

        result = []

        length.times do
          value, offset = type.deserialize(
            data,
            offset: offset,
            program: program
          )
          result << value
        end

        [result, offset]
      end

      def serialize(value, program:)
        result = ScalarTypeDefinition.new(type: :u32).serialize(value.length, program: program)

        value.each do |element|
          result += type.serialize(element, program: program)
        end

        result
      end
    end
  end
end
