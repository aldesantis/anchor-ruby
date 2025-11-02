module Anchor
  module Idl
    class StructTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          new(
            fields: data.fetch("fields", []).map { |field| FieldDefinition.from_data(field) }
          )
        end
      end

      attr_reader :fields

      def initialize(fields:)
        @fields = fields
      end

      def find_field(name)
        fields.find { |field| field.name == name }
      end

      def find_field!(name)
        find_field(name) || raise(ArgumentError, "Field #{name} not found")
      end

      def deserialize(data, offset:, program:)
        result = {}

        fields.each do |field|
          field_value, offset = field.type.deserialize(
            data,
            offset: offset,
            program: program
          )

          result[field.name] = field_value
        end

        [result, offset]
      end

      def serialize(value, program:)
        result = "".b

        fields.each do |field|
          field_name = field.name
          field_value = value[field_name] || value[field_name.to_sym]
          result += field.type.serialize(field_value, program: program)
        end

        result
      end
    end
  end
end
