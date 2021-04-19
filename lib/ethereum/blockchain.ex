defmodule Ethereum.Blockchain do
  
  @doc """
    iex> all_blocks = Ethereum.Blockchain.get_all_blocks()
  """
  @spec get_all_blocks :: {:ok, List.t} | {:error, String.t}
  def get_all_blocks() do
    {:ok, highest_block_num} = Ethereum.Eth.block_number()
    range_floor = 0
    range = highest_block_num..range_floor
    blocks = Enum.map(range, fn blocknum -> 
      {:ok, block} = blocknum |> Ethereum.to_hex() |> Ethereum.get_block_by_number()
      block
    end)
  end

end