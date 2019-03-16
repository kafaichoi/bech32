# Bech32

## Usage
```bash
iex> Bech32.bech32_verify_checksum("A12UEL5L") # more verbose with error mssage
:ok

iex> Bech32.bech32_valid?("A12UEL5L") # return boolean
true
```

### Development
```bash
mix test
mix dialyzer
```