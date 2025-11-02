module Anchor
  module Idl
    class ArrayTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          new(
            type: TypeDefinition.from_data(data.fetch(0)),
            length: data.fetch(1)
          )
        end
      end

      attr_reader :type
      attr_reader :length

      def initialize(type:, length:)
        @type = type
        @length = length
      end

      def deserialize(data, offset:, program:)
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
        unless value.is_a?(Array) && value.length == length
          raise ArgumentError, "Array length mismatch: expected #{length}, got #{value.length}"
        end

        result = "".b

        value.each do |element|
          result += type.serialize(element, program: program)
        end

        result
      end
    end
  end
end
