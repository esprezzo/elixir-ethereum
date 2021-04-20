defmodule Ethereum.Web3 do
  @moduledoc """
  Web3 Namespace Functions for Ethereum JSON-RPC
  """  
  alias Ethereum.Transport
  require IEx
  require Logger
  @doc """
    
  Displays client_version of Ethereum node.

  ## Example:

      iex> Ethereum.client_version()
      {:ok, "Geth/v1.6.5-stable-cf87713d/darwin-amd64/go1.8.3"}
      
  """
  @spec client_version :: {:ok, String.t} | {:error, String.t}
  def client_version do
    case Transport.send("web3_clientVersion") do
      {:ok, version} ->
        {:ok, version}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec decode_event(binary(), binary()) :: any()
  @doc "Decodes event based on given data and provided signature"
  def decode_event(data, signature) do
    formatted_data =
      data
      |> String.slice(2..-1)
      |> Base.decode16!(case: :lower)
    unless signature do
      Logger.warn "decode_event.. signature BLANK!!!"
    else 
      fs = ABI.FunctionSelector.decode(signature)
      ABI.TypeDecoder.decode(formatted_data, fs)
    end
  end

  @doc """

  Creates a sha3 hash of a string.

  ## Example:

      iex> Ethereum.sha3("0x68656c6c6f20776f726c64")
      {:ok, "47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad"}

  """
  @spec sha3(String.t) :: {:ok, float} | {:error, String.t}
  def sha3(str) do
    case Transport.send("web3_sha3",[str]) do
      {:ok, sha} ->
        {:ok, sha}
      {:error, reason} ->
        {:error, reason}
    end

  end

end
