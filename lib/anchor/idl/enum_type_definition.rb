module Anchor
  module Idl
    class EnumTypeDefinition < TypeDefinition
      class << self
        def from_data(data)
          new(
            variants: data.fetch("variants").map { |variant| VariantDefinition.from_data(variant) }
          )
        end
      end

      attr_reader :variants

      def initialize(variants:)
        @variants = variants
      end

      def deserialize(data, offset:, program:)
        discriminant, offset = ScalarTypeDefinition.new(type: :u8).deserialize(
          data,
          offset: offset,
          program: program
        )

        if discriminant < 0 || discriminant >= variants.length
          raise(
            DeserializationError,
            "Invalid enum discriminant: expected 0..#{variants.length - 1}, got #{discriminant}"
          )
        end

        variant = variants.fetch(discriminant)

        variant_data = {}

        variant.fields.each do |field|
          field_value, offset = field.type.deserialize(
            data,
            offset: offset,
            program: program
          )

          variant_data[field.name] = field_value
        end

        [{variant: variant.name, data: variant_data}, offset]
      end

      def serialize(value, program:)
        variant_name = value[:variant] || value["variant"]
        variant_data = value[:data] || value["data"] || {}

        variant_index = variants.index { |v| v.name == variant_name }
        unless variant_index
          raise ArgumentError, "Invalid enum variant: #{variant_name.inspect}"
        end

        variant = variants[variant_index]
        result = ScalarTypeDefinition.new(type: :u8).serialize(variant_index, program: program)

        variant.fields.each do |field|
          field_name = field.name
          field_value = variant_data[field_name] || variant_data[field_name.to_sym]
          result += field.type.serialize(field_value, program: program)
        end

        result
      end
    end
  end
end
