defmodule Ethereum do
  @moduledoc """
  This library presents a convenient interface to control a full Ethereum node from Elixir,
  abstracting away the need to deal with the JSON-RPC API directly.
  It decodes the hex responses when necessary and functions return the idiomatic {:ok, data} | {:error, reason}
  tuples whenever possible. The goal is to cover the entire JSON-RPC API for Geth/Parity.

  The main module acts as an "interface" or "facade".
  It delegates all functionality to submodules for clarity and to keep modules smaller.
  """
  alias Ethereum.Web3
  alias Ethereum.Eth
  alias Ethereum.Net
  alias Ethereum.Personal
  alias Ethereum.Aggregates
  alias Ethereum.HexUtils
  alias Ethereum.ABI
  alias Ethereum.TxPool

  ## Eth Namespace Functions
  defdelegate get_transaction_by_hash(hash), to: Eth
  defdelegate get_transaction_receipt_by_hash(hash), to: Eth
  defdelegate get_block_by_hash(hash, full_txns), to: Eth
  defdelegate get_block_by_number(conn, number, full), to: Eth
  defdelegate get_block_by_number(number, full \\ false), to: Eth
  defdelegate get_balance(account_hash, block \\ "latest"), to: Eth
  defdelegate protocol_version(), to: Eth
  defdelegate syncing(), to: Eth
  defdelegate coinbase(), to: Eth
  defdelegate mining(), to: Eth
  defdelegate hashrate(), to: Eth
  defdelegate gas_price(), to: Eth
  defdelegate accounts(), to: Eth
  defdelegate block_number(), to: Eth
  defdelegate block_number(conn), to: Eth
  defdelegate transaction_count(hash), to: Eth
  defdelegate get_filter_changes(hash), to: Eth
  defdelegate get_filter_logs(hash), to: Eth
  defdelegate eth_call(params), to: Eth
  defdelegate eth_send(transaction), to: Eth, as: :eth_send_transaction
  defdelegate uninstall_filter(id), to: Eth
  defdelegate new_filter(map), to: Eth
  defdelegate transaction_count(hash), to: Eth
  defdelegate get_filter_changes(hash), to: Eth
  defdelegate uninstall_filter(id), to: Eth
  defdelegate new_filter(map), to: Eth

  ## Web3 Namespace Functions
  defdelegate client_version(), to: Web3
  defdelegate sha3(str), to: Web3
  defdelegate decode_abi_event(data, signature), to: Web3, as: :decode_event

  ## Net Namespace Functions
  defdelegate version(), to: Net
  defdelegate peer_count(), to: Net
  defdelegate listening(), to: Net

  ## Personal Namespace Functions
  defdelegate new_account(password, password_confirmation), to: Personal
  defdelegate unlock_account(account, password), to: Personal
  defdelegate lock_account(account), to: Personal
  defdelegate send_transaction(from, to, amount, password), to: Personal

  ## Aggregate/Stats Functions
  defdelegate get_recent_averages(sample_size), to: Aggregates
  defdelegate get_recent_blocks(sample_size), to: Aggregates
  defdelegate get_recent_blocktimes(sample_size), to: Aggregates
  defdelegate get_recent_blocks_with_blocktimes(sample_size), to: Aggregates
  defdelegate get_recent_transactions_per_block(sample_size), to: Aggregates
  defdelegate get_average_blocktime(blocks), to: Aggregates
  defdelegate get_average_difficulty(blocks), to: Aggregates

  ## Encoding + Utils
  defdelegate unhex(str), to: HexUtils
  defdelegate to_hex(str), to: HexUtils
  defdelegate is_valid_address?(address), to: HexUtils
  defdelegate hex_to_decimal(hex_string), to: HexUtils

  ## ABI Functions
  defdelegate load_abi(file), to: ABI
  defdelegate reformat_abi(abi), to: ABI
  defdelegate abi_method_signature(abi, name), to: ABI, as: :method_signature
  defdelegate encode_abi_event(signature), to: ABI, as: :encode_event
  defdelegate encode_abi_data(types_signature, data), to: ABI, as: :encode_data
  defdelegate encode_abi_options(options, keys), to: ABI, as: :encode_options
  defdelegate encode_abi_option(value), to: ABI, as: :encode_option
  defdelegate encode_abi_method_call(abi, name, input), to: ABI, as: :encode_method_call
  defdelegate decode_abi_data(types_signature, data), to: ABI, as: :decode_data
  defdelegate decode_abi_output(abi, name, output), to: ABI, as: :decode_output
  defdelegate abi_keys_to_decimal(map, keys), to: ABI, as: :keys_to_decimal

  # TX Pool functions

end
