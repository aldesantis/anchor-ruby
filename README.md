# Anchor Ruby

A Ruby library for parsing, serializing, and deserializing [Anchor](https://www.anchor-lang.com/docs) data from the Solana blockchain.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anchor-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install anchor-ruby
```

## Usage

### Loading an IDL File

```ruby
require 'anchor'

# Load IDL from a JSON file
program = Anchor::Idl::ProgramDefinition.from_file("path/to/idl.json")

# Or load from hash data
program = Anchor::Idl::ProgramDefinition.from_data(idl_hash)

# Access program metadata
puts program.address  # Program's base58 pubkey
puts program.metadata # Hash of metadata (name, version, etc.)

# Access collections
puts program.instructions  # Array of instruction definitions
puts program.accounts      # Array of account definitions
puts program.errors        # Array of error definitions
puts program.types         # Array of custom type definitions
```

### Finding Definitions by Name

All finder methods have two variants: a safe version that returns `nil` if not found, and a bang version that raises `ArgumentError`:

```ruby
# Find instructions
instruction = program.find_instruction("transfer")      # Returns InstructionDefinition or nil
instruction = program.find_instruction!("transfer")     # Returns InstructionDefinition or raises

# Find accounts
account = program.find_account("UserAccount")           # Returns AccountDefinition or nil
account = program.find_account!("UserAccount")          # Returns AccountDefinition or raises

# Find types
type = program.find_type("TransferConfig")              # Returns type or nil
type = program.find_type!("TransferConfig")             # Returns type or raises

# Find errors
error = program.find_error("InsufficientFunds")         # Returns ErrorDefinition or nil
error = program.find_error!("InsufficientFunds")        # Returns ErrorDefinition or raises
```

### Finding Definitions by Discriminator

Discriminators are 8-byte identifiers used to identify instructions and accounts in binary data:

```ruby
# Find instruction by discriminator (array of 8 bytes)
discriminator = [175, 175, 109, 31, 13, 152, 155, 237]
instruction = program.find_instruction_by_discriminator(discriminator)
instruction = program.find_instruction_by_discriminator!(discriminator)

# Find account by discriminator
account = program.find_account_by_discriminator(discriminator)
account = program.find_account_by_discriminator!(discriminator)
```

### Finding Definitions from Binary Data

The library can automatically extract discriminators from binary data:

```ruby
# From instruction data (first 8 bytes are the discriminator)
instruction_data = binary_data_from_blockchain
instruction = program.find_instruction_from_data(instruction_data)
instruction = program.find_instruction_from_data!(instruction_data)

# From account data (first 8 bytes are the discriminator)
account_data = binary_data_from_blockchain
account = program.find_account_from_data(account_data)
account = program.find_account_from_data!(account_data)
```

### Deserializing Instructions

Deserialize instruction data from the blockchain:

```ruby
# Get the instruction definition
instruction_def = program.find_instruction!("transfer")

# Deserialize binary instruction data
# Returns a DeserializedInstruction with args and accounts hashes
deserialized = instruction_def.deserialize(
  instruction_data,        # Binary data from blockchain
  account_addresses,       # Array of account pubkeys
  program: program         # Program definition for recursive types
)

puts deserialized.args     # Hash of instruction arguments (symbolized keys)
# => { amount: 1000, recipient: "..." }

puts deserialized.accounts # Hash of account addresses (symbolized keys)
# => { authority: "DrUi...", from: "Tokenkeg..." }
```

### Serializing Instructions

Create binary instruction data for transactions:

```ruby
# Get the instruction definition
instruction_def = program.find_instruction!("transfer")

# Serialize arguments to binary
instruction_data = instruction_def.serialize(
  args: {
    amount: 1000,
    recipient: "DrUiXQqZdaYBLqW8Qrc1Vxun6KZ8fXa8cX5Fk5XZkZk"
  },
  program: program
)

# instruction_data is ready to be included in a transaction
```

### Deserializing Account Data

```ruby
# Get the account definition
account_def = program.find_account!("UserAccount")

# Validate the account discriminator
account_def.valid_discriminator?(account_data)    # => true/false
account_def.validate_discriminator!(account_data) # Raises InvalidDiscriminatorError if invalid

# Get the type definition for this account
type_def = program.find_type!(account_def.name).type

# Deserialize binary account data (skip 8-byte discriminator)
result, _offset = type_def.deserialize(account_data, offset: 8, program: program)

# result is a Hash with account fields
puts result[:balance]  # => 5000
puts result[:owner]    # => "..." (pubkey as base58 string)
```

### Working with Error Definitions

```ruby
# Find error definition
error = program.find_error!("InsufficientFunds")

puts error.name  # => "InsufficientFunds"
puts error.code  # => 6000
puts error.msg   # => "Insufficient funds for transfer"
```

### Working with Instructions and Accounts

```ruby
instruction = program.find_instruction!("transfer")

# Access instruction metadata
puts instruction.name
puts instruction.discriminator  # Array of 8 bytes

# Inspect accounts
instruction.accounts.each do |account_def|
  puts account_def.name
  puts account_def.writable    # true/false
  puts account_def.signer      # true/false
  puts account_def.optional    # true/false
  puts account_def.address     # Fixed address if specified
  puts account_def.relations   # Array of relation strings
  
  # PDA configuration
  if account_def.pda
    account_def.pda.seeds.each do |seed|
      puts seed.kind   # "const" or "account" or "arg"
      puts seed.value  # Constant value
      puts seed.path   # Field path for account/arg types
    end
    
    puts account_def.pda.program  # Program reference if specified
  end
end

# Inspect arguments
instruction.args.each do |arg_def|
  puts arg_def.name
  puts arg_def.type  # TypeDefinition instance
end
```

### Working with Custom Types

```ruby
# Get a custom type definition
field_def = program.find_type!("TransferConfig")
type_def = field_def.type  # The actual TypeDefinition

# For struct types
if type_def.is_a?(Anchor::Idl::StructTypeDefinition)
  type_def.fields.each do |field|
    puts field.name
    puts field.type
  end
  
  # Find a specific field
  balance_field = type_def.find_field!("balance")
end

# For enum types
if type_def.is_a?(Anchor::Idl::EnumTypeDefinition)
  type_def.variants.each do |variant|
    puts variant.name
    variant.fields.each do |field|
      puts field.name
      puts field.type
    end
  end
end
```

## Supported IDL Types

The library supports all Anchor IDL type definitions with full serialization and deserialization:

### Scalar Types

Basic primitive types:

- **Unsigned integers**: `u8`, `u16`, `u32`, `u64`
- **Signed integers**: `i8`, `i16`, `i32`, `i64`
- **Boolean**: `bool`
- **String**: `string` (UTF-8 encoded with length prefix)
- **Bytes**: `bytes` (variable length with length prefix)
- **Public Key**: `pubkey` (32 bytes, deserialized as Base58 string)

### Struct Types

Named collections of fields:

```ruby
# Deserializes to Hash with symbolized keys
result = struct_type.deserialize(data, offset: 0, program: program)
# => { balance: 1000, owner: "DrUi..." }

# Serializes from Hash
binary = struct_type.serialize({ balance: 1000, owner: pubkey }, program: program)
```

### Enum Types

Rust-style discriminated unions:

```ruby
# Deserializes to Hash with :variant and :data keys
result = enum_type.deserialize(data, offset: 0, program: program)
# => { variant: "Transfer", data: { amount: 1000 } }

# Serializes from Hash
binary = enum_type.serialize({ variant: "Transfer", data: { amount: 1000 } }, program: program)
```

### Container Types

Generic wrappers around other types:

- **Vec<T>**: Variable-length arrays (`VecTypeDefinition`)
- **Option<T>**: Optional values (`OptionTypeDefinition`)
- **[T; N]**: Fixed-length arrays (`ArrayTypeDefinition`)

### Defined Types

References to custom types defined in the IDL:

```ruby
# Resolves to the actual type definition
type_def = program.find_type!("MyStruct").type
```

### Nested Types

Types can be arbitrarily nested:

```ruby
# Example: Vec<Option<UserAccount>>
vec_of_optional_accounts.deserialize(data, offset: 0, program: program)
# => [nil, { balance: 100, owner: "..." }, nil, { balance: 200, owner: "..." }]
```

## Error Handling

The library defines several error types:

### DeserializationError

Raised when type deserialization fails:

```ruby
begin
  type_def.deserialize(invalid_data, offset: 0, program: program)
rescue Anchor::Idl::DeserializationError => e
  puts e.message  # Detailed error about what went wrong
end
```

### InvalidDiscriminatorError

Raised when account discriminator validation fails:

```ruby
begin
  account_def.validate_discriminator!(account_data)
rescue Anchor::Idl::AccountDefinition::InvalidDiscriminatorError => e
  puts "Account data doesn't match expected type"
end
```

### ArgumentError

Raised by bang finder methods when definitions are not found:

```ruby
begin
  program.find_instruction!("nonexistent")
rescue ArgumentError => e
  puts e.message  # "Instruction nonexistent not found in IDL"
end
```

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aldesantis/anchor-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
