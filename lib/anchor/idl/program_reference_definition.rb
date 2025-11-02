module Anchor
  module Idl
    class ProgramReferenceDefinition
      attr_reader :kind
      attr_reader :value
      attr_reader :path

      class << self
        def from_data(data)
          new(
            kind: data.fetch("kind"),
            value: data["value"],
            path: data["path"]
          )
        end
      end

      def initialize(kind:, value: nil, path: nil)
        @kind = kind
        @value = value
        @path = path
      end

      def as_json
        {
          kind: kind,
          value: value,
          path: path
        }
      end
    end
  end
end
