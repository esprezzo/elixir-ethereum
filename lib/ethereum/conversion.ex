defmodule Ethereum.Conversion do
  @moduledoc """
    Various Wei/Ethereum Eth Style Unit Conversion Functions
  """
  require IEx
  require Logger

  alias Ethereum.Units
  @units %Units{}

  @spec wei_to_eth(integer) :: float
  def wei_to_eth(wei) do
    wei / @units.eth
  end

  @spec format_units(integer, integer) :: float
  def format_units(atomic_units, decimals) do
    divisor = :math.pow(10, decimals)
    if atomic_units && divisor do
      atomic_units / divisor
    else 
      Logger.error "MATH ERROR IN Ethereum.format_units(#{atomic_units}, #{divisor})"
      0
    end
  end
  
  @spec to_wei(amount :: integer, denomination :: atom) :: integer()
  def to_wei(amount, denomination) do
    case denomination do
      :ether ->
        @units.eth * amount |> Kernel.round()
      _ ->
        0
    end

  end

end

