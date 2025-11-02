module Anchor
  module Idl
    class InstructionAccountDefinition
      attr_reader :name
      attr_reader :writable
      attr_reader :signer
      attr_reader :optional
      attr_reader :pda
      attr_reader :relations
      attr_reader :address

      class << self
        def from_data(data)
          new(
            name: data.fetch("name"),
            writable: data.fetch("writable", false),
            signer: data.fetch("signer", false),
            optional: data.fetch("optional", false),
            pda: data["pda"] ? PdaDefinition.from_data(data["pda"]) : nil,
            relations: data.fetch("relations", []),
            address: data["address"]
          )
        end
      end

      def initialize(name:, writable: false, signer: false, optional: false, pda: nil, relations: [], address: nil)
        @name = name
        @writable = writable
        @signer = signer
        @optional = optional
        @pda = pda
        @relations = relations
        @address = address
      end
    end
  end
end
