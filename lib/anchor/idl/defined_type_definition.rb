module Anchor
  module Idl
    class DefinedTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          name = data.is_a?(Hash) ? data.fetch("name") : data
          new(name: name)
        end
      end

      attr_reader :name

      def initialize(name:)
        @name = name
      end

      def deserialize(data, offset:, program:)
        type = program.find_type!(name).type
        type.deserialize(data, offset: offset, program: program)
      end

      def serialize(value, program:)
        type = program.find_type!(name).type
        type.serialize(value, program: program)
      end
    end
  end
end
