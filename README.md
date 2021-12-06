# Elixir-Ethereum


## Elixir interface to Ethereum JSON-RPC w/smart contract support
This library presents a convenient interface to control one or more Ethereum nodes using the Elixir programming language. It abstracts away the need to deal with the JSON-RPC API directly and handles hex encoding/decoding when needed. 

Functions return the idiomatic `{:ok, data} | {:error, reason}` tuples whenever possible. The goal is to cover the entire JSON-RPC API of the standard Geth implemetation.

This project aims to have @specs for every function and is using Dialyzer + ExUnit for testing/linting.


Recent Updates:
  - Ability to set proc name of contract manager so we can run several simulatenously



### Examples of Currently Implemented JSON-RPC methods
```
iex> Ethereum.client_version
{:ok, "v1.6.5-stable-cf87713d/darwin-amd64/go1.8.3"}

iex> Ethereum.sha3("0x68656c6c6f20776f726c64")
{:ok, "47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad"}

iex> Ethereum.net_version
{:ok, "1"}

iex> Ethereum.peer_count
{:ok, "19"}

iex> Ethereum.listening
{:ok, true}

iex> Ethereum.protocol_version
{:ok, 63}

iex> Ethereum.syncing
{:ok, false}

iex> Ethereum.coinbase
{:ok, "78fc2b9b6cf9b18f91037a5e0e074a479be9dca1"}

iex> Ethereum.mining
{:ok, true}

iex> Ethereum.hashrate
{:ok, "0"}

iex> Ethereum.gas_price
{:ok, 22061831512}

iex> Ethereum.accounts
{:ok, ["0x78fc2b9b6cf9b18f91037a5e0e074a479be9dca1",
  "0x141feb71895530f537c847d62f039d9be895bd35",
  "0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e",
  "0x50172f916cb2e64172919090af4ff0ba4638d8dd"]}

iex> Ethereum.block_number
{:ok, 3858216}

iex> Ethereum.get_balance("0xfE8bf4ca8A6170E759E89EDB5cc9adec3e33493f") # Donations accepted :-)
{:ok, 0.4650075166583676}

iex> Ethereum.transaction_count("0xfE8bf4ca8A6170E759E89EDB5cc9adec3e33493f")
{:ok, 3858216}

iex> Ethereum.new_account("h4ck3r", "h4ck3r")
{:ok, "50172f916cb2e64172919090af4ff0ba4638d8dd"}

iex> Ethereum.unlock_account("0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e", "h4ck3r")
{:ok, true}

iex> Ethereum.lock_account("0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e")
{:ok, true}

iex> Ethereum.send_transaction("0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e", "0xfE8bf4ca8A6170E759E89EDB5cc9adec3e33493f", 0.00043, "h4ck3r")
{:ok, "88c646f79ecb2b596f6e51f7d5db2abd67c79ff1f554e9c6cd2915f486f34dcb"}
```

## Complete list of currently implemeted features:
### Eth Namespace Functions
```
- defdelegate get_transaction_by_hash(hash), to: Eth
- defdelegate get_transaction_receipt_by_hash(hash), to: Eth
- defdelegate get_block_by_hash(hash, full_txns), to: Eth
- defdelegate get_block_by_number(number, full \\ false), to: Eth
- defdelegate get_balance(account_hash), to: Eth
- defdelegate protocol_version(), to: Eth
- defdelegate syncing(), to: Eth
- defdelegate coinbase(), to: Eth
- defdelegate mining(), to: Eth
- defdelegate hashrate(), to: Eth
- defdelegate gas_price(), to: Eth
- defdelegate accounts(), to: Eth
- defdelegate block_number(), to: Eth
- defdelegate transaction_count(hash), to: Eth
- defdelegate get_filter_changes(hash), to: Eth
- defdelegate eth_call(params), to: Eth
- defdelegate eth_send(transaction), to: Eth, as: - :eth_send_transaction
- defdelegate uninstall_filter(id), to: Eth
- defdelegate new_filter(map), to: Eth
```

### Web3 Namespace Functions
```
- defdelegate client_version(), to: Web3
- defdelegate sha3(str), to: Web3
```

### Net Namespace Functions
```
- defdelegate version(), to: Net
- defdelegate peer_count(), to: Net
- defdelegate listening(), to: Net
```

### Personal Namespace Functions
```
- defdelegate new_account(password, password_confirmation), to: Personal
- defdelegate unlock_account(account, password), to: Personal
- defdelegate lock_account(account), to: Personal
- defdelegate send_transaction(from, to, amount, password), to: Personal
```

### Aggregate/Stats Functions
```
- defdelegate get_recent_averages(sample_size), to: Aggregates
- defdelegate get_recent_blocks(sample_size), to: Aggregates
- defdelegate get_recent_blocktimes(sample_size), to: Aggregates
- defdelegate get_recent_blocks_with_blocktimes(sample_size), to: Aggregates
- defdelegate get_recent_transactions_per_block(sample_size), to: Aggregates
- defdelegate get_average_blocktime(blocks), to: Aggregates
- defdelegate get_average_difficulty(blocks), to: Aggregates
```

### Encoding + Utils 
```
- defdelegate unhex(str), to: HexUtils
- defdelegate to_hex(str), to: HexUtils
- defdelegate is_valid_address?(address), to: HexUtils
- defdelegate hex_to_decimal(hex_string), to: HexUtils
```

### ABI Functions
```
defdelegate load_abi(file), to: ABI
defdelegate reformat_abi(abi), to: ABI
defdelegate abi_method_signature(abi, name), to: ABI, as: :method_signature
defdelegate encode_abi_event(signature), to: ABI, as: :encode_event
defdelegate encode_abi_data(signature), to: ABI, as: :encode_data
defdelegate encode_abi_options(options, keys), to: ABI, as: :encode_options
defdelegate encode_abi_option(value), to: ABI, as: :encode_option
defdelegate encode_abi_method_call(abi, name, input), to: ABI, as: :encode_method_call
defdelegate decode_abi_data(types_signature, data), to: ABI, as: :decode_data
defdelegate decode_abi_output(abi, name, output), to: ABI, as: :decode_output
defdelegate decode_abi_event(data, signature), to: ABI, as: :decode_event
defdelegate abi_keys_to_decimal(map, keys), to: ABI, as: :keys_to_decimal
```


## Installation
## hex.pm
```elixir
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `esprezzo_ethereum` to your list of dependencies in `mix.exs`:
def deps do
  [{:esprezzo_ethereum, "~> 0.1.0"}]
end

Right now you should use the Github:
def deps do
  [{:esprezzo_ethereum, "GITHUB_ADDRESS"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)

TODO/Contribution:

Pull requests welcomed. This library also includes some of the more commonly used "admin" and "personal" API functions which will require the node to be started with `--rpcapi "db,eth,net,web3,personal"`. The sensitive interfaces should only be done in a safe network environment if at all.
