defmodule Ethereum.Aggregates do
  @moduledoc """
  Functions to return metadata and other more useful stats/data than the node returns natively.
  """
  require IEx

  @doc """
  Return recent average difficulty, blocktime, and nethash for last N blocks

  ## Example:

      iex> Ethereum.get_recent_averages(20)

  """
  @spec get_recent_averages(integer()) :: {:ok, float(), float(), float()} | {:error, String.t}
  def get_recent_averages(sample_size) do
    blocks = get_recent_blocks(sample_size) 
    average_difficulty = get_average_difficulty(blocks)
    average_blocktime = get_average_blocktime(blocks)
    average_nethash = average_difficulty / average_blocktime
    {:ok, {average_blocktime, average_difficulty, average_nethash}}
  end

  @doc """
  Get a recent chunk of blocks

  ## Example:
      
    iex> Ethereum.get_recent_blocks(10)
  
  """
  @spec get_recent_blocks(binary()) :: float
  def get_recent_blocks(sample_size) do
    {:ok, highest_block_num} = Ethereum.block_number()
    range_floor = highest_block_num - (sample_size - 1)
    range = highest_block_num..range_floor
    blocks = Enum.map(range, fn blocknum -> 
      {ok, block} = 
        blocknum 
          |> Ethereum.get_block_by_number()
      block
    end)
  end

  @doc """
  Get average blocktime from sample set of blocks

  ## Example:

      iex> Ethereum.get_average_blocktime(blocks)

  """
  @spec get_average_blocktime(List.t) :: float
  def get_average_blocktime(blocks) do
    [head | tail ] = blocks
    last_timestamp = head["timestamp"] |> Ethereum.unhex()
    {_, sample_total} = Enum.reduce(tail, {last_timestamp, 0}, 
      fn(block, {previous_timestamp, interval_total}) -> 
        current_timestamp = Ethereum.unhex(block["timestamp"])
        interval = previous_timestamp - current_timestamp
        interval_total = interval_total + interval
        {current_timestamp, interval_total}
      end)
    sample_total / Enum.count(tail)
  end

  @doc """
  Get average difficulty from sample set of blocks

  ## Example:
        
      iex> Ethereum.get_average_difficulty(blocks)

  """
  @spec get_average_difficulty(binary()) :: float
  def get_average_difficulty(blocks) do
    [first_block | _ ] = blocks
    seed_acc = first_block["difficulty"] |> Ethereum.unhex()
    total_diff = Enum.reduce(blocks, seed_acc, fn(block, acc) -> 
      acc + Ethereum.unhex(block["difficulty"])
    end)
    average_diff = total_diff / Enum.count(blocks)
  end

  @doc """
  Get recent blocktimes as useful for a timeseries history chart

  ## Example:
      
      iex> Ethereum.Aggregates.get_recent_blocktimes(20)
  
  """
  @spec get_recent_blocktimes(integer()) :: List.t()
  def get_recent_blocktimes(sample_size) do
    all = get_recent_blocks(sample_size + 1) |> Enum.reverse() # |> Enum.map(fn x -> Map.put(x, "number_int", Ethereum.unhex(x["number"])) end)
    [head | tail ] = all
    last_timestamp = head |> Map.get("timestamp") |> Ethereum.unhex()
    {_, recent_blocktimes} = Enum.reduce(tail, {last_timestamp, []}, 
    fn(block, {previous_timestamp, all_intervals}) -> 
      current_timestamp = Ethereum.unhex(block["timestamp"])
      interval = current_timestamp - previous_timestamp
      number = Ethereum.unhex(block["number"])
      {current_timestamp, all_intervals ++ [[number,interval]]}
    end)
    recent_blocktimes
  end

  @doc """
  Get a chunk of blocks with blocktime info

  ## Example:

      iex> Ethereum.get_recent_blocktimes(20)
  
  """
  @spec get_recent_blocks_with_blocktimes(integer()) :: List.t()
  def get_recent_blocks_with_blocktimes(sample_size) do
    all = get_recent_blocks(sample_size + 1) |> Enum.reverse()
    [head | tail ] = all
    last_timestamp = head |> Map.get("timestamp") |> Ethereum.unhex()
    {_, recent_blocks} = Enum.reduce(tail, {last_timestamp, []}, 
    fn(block, {previous_timestamp, blocks}) -> 
      current_timestamp = Ethereum.unhex(block["timestamp"])
      # interval = :os.system_time(:seconds) - previous_timestamp
      number = Ethereum.unhex(block["number"])
      b = %{
        number: number,
        hash: block["hash"],
        timestamp: current_timestamp,
        transaction_count: Enum.count(block["transactions"]),
        extra_data: decode_extra(block["extraData"])
      }
      {current_timestamp, blocks ++ [b]}
    end)
    recent_blocks |> Enum.reverse
  end

  @doc """
  Get transactions count for recent blocks as useful for a timeseries history chart.

  ## Example: 

      iex> Ethereum.get_recent_transactions_per_block(20)

  """
  @spec get_recent_transactions_per_block(integer) :: List.t()
  def get_recent_transactions_per_block(sample_size) do
    blocks = get_recent_blocks(sample_size)
    recent_transactions_per_block = Enum.map(blocks, fn block -> 
      number = Ethereum.unhex(block["number"])
      txn_count = Enum.count(block["transactions"])
      [number, txn_count]
    end) 
    |> Enum.reverse()
  end

  @doc """
  Decode the extra_data field on a block // private

  ## Example: 
      
      iex> decode_extra(data)
  """
  @spec decode_extra(String.t()) :: String.t() 
  defp decode_extra(input) do
    if input do
      case input |> String.slice(2..-1) |> String.upcase |> Base.decode16 do
        {:ok, str} -> 
          case String.valid?(str) do
            true -> str
            false -> false
          end
        :error -> :error
      end
    else
      :error
    end
  end

  
end