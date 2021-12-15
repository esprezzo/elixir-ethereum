defmodule Ethereum.Eth do
  @moduledoc """
  Eth Namespace for Ethereum JSON-RPC
  RPC calls
  """
  alias Ethereum.Transport
  alias Ethereum.Conversion
  require IEx
  require Logger


  @doc """
  Show best/highest block number

  ## Example:

      iex> Ethereum.block_number()
      {:ok, 3858216}

  """
  @spec block_number :: {:ok, integer} | {:error, String.t}
  def block_number do
    case Transport.send("eth_blockNumber",[]) do
      {:ok, resp} ->
        decoded_number = resp
          |> Hexate.to_integer
        {:ok, decoded_number}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec block_number(map()) :: {:ok, integer} | {:error, String.t}
  def block_number(conn) do
    case Transport.send_fast(conn, "eth_blockNumber",[], false) do
      {:ok, resp} ->
        decoded_number = resp
          |> Hexate.to_integer
        {:ok, decoded_number}
      {:error, reason} ->
        {:error, reason}
    end
  end
  @doc """
  Get balance of Ethereum account by hash

  ## Example:

      Ethereum.get_balance("0xfE8bf4ca8A6170E759E89EDB5cc9adec3e33493f")
      {:ok, 0.4650075166583676}
  """
  @spec get_balance(String.t()) :: {:ok, float} | {:error, String.t()}
  def get_balance(account_hash, blockNum \\ "latest") do
    case Transport.send("eth_getBalance",[account_hash, blockNum]) do
      {:ok, wei_val} ->
        unless wei_val, do: wei_val = 0
        ether_val = wei_val
        |> Hexate.to_integer
        |> Conversion.wei_to_eth
        {:ok, ether_val}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  """
  def eth_call(params) do
    [h | t] = params
    case Transport.send("eth_call", [h, "latest"], false) do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get block by number or default to latest.

  ## Example:

      iex> Ethereum.get_block_by_number(43, false)
      {:ok,  %{"difficulty" => "0x40e990afb", ...}}

  """
  @spec get_block_by_number(map(), binary(), boolean()) :: {:ok, integer} | {:error, String.t}
  def get_block_by_number(conn, number, full) do
    hex_num = "0x" <> Hexate.encode(number)
    case Transport.send_fast(conn, "eth_getBlockByNumber",[hex_num, full], false) do
      {:ok, block} ->
        decoded_block = block
        {:ok, decoded_block}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get block by hash

  ## Example:

      iex> Ethereum.get_block_by_hash("0xb8bbe729e16b9aa1b30c157c7d799ddb68814ae183cf6a1c9d3597916e54f50f")
      {:ok,
        %{
          "difficulty" => "0x4118100c961",
          "extraData" => "0x476574682f76312e302e322f6c696e75782f676f312e342e32",
          ...
        }
      }

  """
  @spec get_block_by_hash(binary(), boolean()) :: {:ok, binary()} | {:error, String.t}
  def get_block_by_hash(hash, full \\ false) do
    case Transport.send("eth_getBlockByHash",[hash, full]) do
      {:ok, block} ->
        {:ok, block}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Get Ethereum Protocol Version

  ## Example:

      iex> Ethereum.protocol_version()
      {:ok, 63}

  """
  @spec protocol_version :: {:ok, integer} | {:error, String.t}
  def protocol_version do
    case Transport.send("eth_protocolVersion",[]) do
      {:ok, version} ->
        decoded_version = version
          |> Hexate.to_integer
        {:ok, decoded_version}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get current sync status of Ethereum node

  ## Example:

      iex> Ethereum.syncing()
      {:ok, false}

  """
  @spec syncing() :: {:ok, boolean()} | {:error, String.t}
  def syncing do
    case Transport.send("eth_syncing") do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Get coinbase address for Ethereum node

  ## Example:

      iex> Ethereum.coinbase()
      {:ok, false}

  """
  @spec coinbase() :: {:ok, String.t} | {:error, String.t}
  def coinbase do
    case Transport.send("eth_coinbase",[]) do
      {:ok, hash} ->
        {:ok, hash}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Get current mining status for Ethereum node

  ## Example:

      iex> Ethereum.mining()
      {:ok, true}

  """
  @spec mining() :: {:ok, boolean} | {:error, String.t}
  def mining do
    case Transport.send("eth_mining") do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Get current hashrate of Ethereum network

  ## TODO: Check definition

  ## Example:

      iex> Ethereum.hashrate()
      {:ok, "0"}

  """
  @spec hashrate() :: {:ok, String.t} | {:error, String.t}
  def hashrate do
    case Transport.send("eth_hashrate") do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Show current gas price of node

  ## Example:

      iex> Ethereum.gas_price()
      {:ok, 22061831512}

  """
  @spec gas_price() :: {:ok, String.t} | {:error, String.t}
  def gas_price do
    case Transport.send("eth_gasPrice") do
      {:ok, result} ->
        price = result
          |> Hexate.to_integer
        {:ok, price}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  List accounts managed by connected node

  ## Example:

      iex> Ethereum.accounts()
      {:ok, ["0x78fc2b9b6cf9b18f91037a5e0e074a479be9dca1",
        "0x141feb71895530f537c847d62f039d9be895bd35",
        "0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e",
        "0x50172f916cb2e64172919090af4ff0ba4638d8dd"]}

  """
  @spec accounts() :: {:ok, list} | {:error, String.t}
  def accounts do
    case Transport.send("eth_accounts") do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end




  @doc """
  Show transactions count for block by hash

  ## TODO: Check input to see if "latest" works

  ## Example:

      iex> Ethereum.transaction_count("0xfE8bf4ca8A6170E759E89EDB5cc9adec3e33493f")
      {:ok, 3858216}

  """
  @spec transaction_count(account_hash :: String.t) :: {:ok, integer} | {:error, String.t}
  def transaction_count(account_hash) do
    case Transport.send("eth_getTransactionCount",[account_hash, "latest"]) do
      {:ok, block} ->
        decoded_number = block
          |> Hexate.to_integer
        {:ok, decoded_number}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Show transaction for hash

  ## Example:

      iex> Ethereum.get_transaction_by_hash("0xbbdea9b303ba7b605130ce0c2dd261893a086f7221511d7a31964c4aab70dca3")
      {:ok, 3858216}

  """
  @spec get_transaction_by_hash(binary()) :: {:ok, binary()} | {:error, String.t}
  def get_transaction_by_hash(hash) do
    case Transport.send("eth_getTransactionByHash",[hash]) do
      {:ok, txn} ->
        decoded_txn = txn
        {:ok, txn}
      {:error, reason} ->
        {:error, reason}
    end
  end


@doc """
  Get logs for EXISTING filter ID

  ## Example:

      iex> get_filter_logs(filter_hash)
      {:ok, 3858216}

"""
@spec get_filter_logs(binary()) :: {:ok, binary()} | {:error, String.t}
def get_filter_logs(hash) do
  case Transport.send("eth_getFilterLogs", [hash]) do
    {:ok, logs} ->
      {:ok, logs}
    {:error, reason} ->
      {:error, reason}
  end
end

@doc """
  Show transaction for hash

  ## Example:

      iex> Ethereum.get_transaction_by_hash("0xbbdea9b303ba7b605130ce0c2dd261893a086f7221511d7a31964c4aab70dca3")
      {:ok, 3858216}

  """
  @spec get_filter_changes(binary()) :: {:ok, binary()} | {:error, String.t}
  def get_filter_changes(hash) do
    case Transport.send("eth_getFilterChanges",[hash]) do
      {:ok, logs} ->
        {:ok, logs}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
    Uninstall Filter

  ## Example:

      iex> Ethereum.uninstall_filter("0x")
      {:ok, _}

  """
  @spec uninstall_filter(binary()) :: {:ok, binary()} | {:error, String.t}
  def uninstall_filter(hash) do
    case Transport.send("eth_uninstallFilter",[hash]) do
      {:ok, res} ->
        {:ok, res}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  New Filter

  ## Example:

      iex> Ethereum.uninstall_filter("0x")
      {:ok, _}

  """
  @spec new_filter(map()) :: {:ok, binary()} | {:error, String.t}
  def new_filter(map) do
    case Transport.send("eth_newFilter",[map]) do
      {:ok, res} ->
        Logger.warn "Ethereum.Eth.new_filter"
        {:ok, res}
      {:error, reason} ->
        {:error, reason}
    end
  end

@doc """
  Show transaction receipt for hash

  ## Example:
      iex> Ethereum.get_transaction_receipt_by_hash("0x6911ae06acd22106a21762af4ce3a8c93156358b6679ccc905ebfab1c34c6e63")
      %{
        "blockHash" => "0x425f2820d6ec8ba444d825fb7548b21f2e9e6496a074b9038eca864218673eee",
        "blockNumber" => "0x3",
        "contractAddress" => "0x7299df2eee42f805dc7aea41e3832e446956687e",
        "cumulativeGasUsed" => "0x1107e4",
        "from" => "0xf861d6125ff060a13d059624b26ce8045b99bf17",
        "gasUsed" => "0x1107e4",
        "logs" => [%{...}]
      }
  """
  @spec get_transaction_receipt_by_hash(binary()) :: {:ok, binary()} | {:error, String.t}
  def get_transaction_receipt_by_hash(hash) do
    case Transport.send("eth_getTransactionReceipt",[hash]) do
      {:ok, txn} ->
        decoded_txn = txn
        {:ok, txn}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """

  """
  def eth_send_transaction(params) do
    [h | t] = params
    case Transport.send("eth_sendTransaction", [h], false) do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end

  # PENDING ADDITIONS
  @doc false
  @spec get_storage_at(String.t) :: {:ok, integer} | {:error, String.t}
  def get_storage_at(hash) do
    {:error, "pending"}
  end

  @doc false
  @spec block_transaction_count_by_hash(String.t) :: {:ok, integer} | {:error, String.t}
  def block_transaction_count_by_hash(hash) do
    {:error, "pending"}
  end

  @doc false
  @spec block_transaction_count_by_number(integer) :: {:ok, integer} | {:error, String.t}
  def block_transaction_count_by_number(n) do
    {:error, "pending"}
  end

  @doc false
  @spec uncle_count_by_block_hash(String.t) :: {:ok, integer} | {:error, String.t}
  def uncle_count_by_block_hash(hash) do
    {:error, "pending"}
  end

  @doc false
  @spec uncle_count_by_block_number(integer) :: {:ok, integer} | {:error, String.t}
  def uncle_count_by_block_number(n) do
    {:error, "pending"}
  end

end
