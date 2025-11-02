module Anchor
  module Idl
    class VariantDefinition
      class << self
        def from_data(data)
          new(
            name: data.fetch("name"),
            fields: data.fetch("fields", []).map { |field| FieldDefinition.from_data(field) }
          )
        end
      end

      attr_reader :name
      attr_reader :fields

      def initialize(name:, fields:)
        @name = name
        @fields = fields
      end
    end
  end
end
