# frozen_string_literal: true

require "json"
require "base64"
require "digest"

require_relative "anchor/base58_encoder"
require_relative "anchor/idl/deserialization_error"
require_relative "anchor/idl/type_definition"
require_relative "anchor/idl/scalar_type_definition"
require_relative "anchor/idl/struct_type_definition"
require_relative "anchor/idl/enum_type_definition"
require_relative "anchor/idl/defined_type_definition"
require_relative "anchor/idl/option_type_definition"
require_relative "anchor/idl/vec_type_definition"
require_relative "anchor/idl/array_type_definition"
require_relative "anchor/idl/field_definition"
require_relative "anchor/idl/variant_definition"
require_relative "anchor/idl/instruction_arg_definition"
require_relative "anchor/idl/instruction_account_definition"
require_relative "anchor/idl/instruction_definition"
require_relative "anchor/idl/account_definition"
require_relative "anchor/idl/error_definition"
require_relative "anchor/idl/seed_definition"
require_relative "anchor/idl/pda_definition"
require_relative "anchor/idl/program_reference_definition"
require_relative "anchor/idl/program_definition"

module Anchor
  class Error < StandardError; end
end
