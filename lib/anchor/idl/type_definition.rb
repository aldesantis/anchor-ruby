module Anchor
  module Idl
    class TypeDefinition
      class << self
        def from_data(data)
          type = if data.is_a?(String)
            ScalarTypeDefinition.from_data(data)
          elsif data.is_a?(Hash)
            if data.key?("kind")
              case data.fetch("kind")
              when "struct"
                StructTypeDefinition.from_data(data)
              when "enum"
                EnumTypeDefinition.from_data(data)
              end
            elsif data.key?("defined")
              DefinedTypeDefinition.from_data(data.fetch("defined"))
            elsif data.key?("option")
              OptionTypeDefinition.from_data(data.fetch("option"))
            elsif data.key?("vec")
              VecTypeDefinition.from_data(data.fetch("vec"))
            elsif data.key?("array")
              ArrayTypeDefinition.from_data(data.fetch("array"))
            end
          end

          type || raise(ArgumentError, "Unknown type definition for: #{data.inspect}")
        end
      end

      def deserialize(data, offset:, program:)
        raise NotImplementedError, "Type definitions must implement #deserialize"
      end

      def serialize(value, program:)
        raise NotImplementedError, "Type definitions must implement #serialize"
      end
    end
  end
end
