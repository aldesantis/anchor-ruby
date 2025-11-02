module Anchor
  module Idl
    class PdaDefinition
      attr_reader :seeds
      attr_reader :program

      class << self
        def from_data(data)
          new(
            seeds: data.fetch("seeds").map { |seed_data| SeedDefinition.from_data(seed_data) },
            program: data["program"] ? ProgramReferenceDefinition.from_data(data["program"]) : nil
          )
        end
      end

      def initialize(seeds:, program: nil)
        @seeds = seeds
        @program = program
      end

      def as_json
        {
          seeds: seeds.map(&:as_json),
          program: program&.as_json
        }
      end
    end
  end
end
