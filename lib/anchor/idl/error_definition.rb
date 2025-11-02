module Anchor
  module Idl
    class ErrorDefinition
      attr_reader :code
      attr_reader :name
      attr_reader :msg

      class << self
        def from_data(data)
          new(
            code: data.fetch("code"),
            name: data.fetch("name"),
            msg: data.fetch("msg")
          )
        end
      end

      def initialize(code:, name:, msg:)
        @code = code
        @name = name
        @msg = msg
      end
    end
  end
end
