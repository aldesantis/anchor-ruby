module Anchor
  module Idl
    class FieldDefinition
      attr_reader :name
      attr_reader :type

      class << self
        def from_data(data)
          new(
            name: data.fetch("name"),
            type: TypeDefinition.from_data(data.fetch("type"))
          )
        end
      end

      def initialize(name:, type:)
        @name = name
        @type = type
      end
    end
  end
end
