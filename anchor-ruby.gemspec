# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "anchor-ruby"
  spec.version = "0.1.0"
  spec.authors = ["Alessandro Desantis"]
  spec.email = ["desa.alessandro@gmail.com"]

  spec.summary = "Ruby library for parsing and deserializing Anchor IDL files"
  spec.description = "A Ruby library for working with Anchor IDL (Interface Definition Language) files from the Solana blockchain. Supports parsing IDL JSON files and deserializing on-chain data."
  spec.homepage = "https://github.com/aldesantis/anchor-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aldesantis/anchor-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/aldesantis/anchor-ruby/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "base64", "~> 0.2"
end
