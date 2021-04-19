defmodule Ethereum.Personal do
  @moduledoc """
    Personal namespace for Ethereum JSON-RPC
    This could be considered dangerous as it requires the admin api to be exposed over JSON-RPC. 
    Use only in a safe environment and see README to enable this namespace in Geth.
  """
  alias Ethereum.Transport
  alias Ethereum.Conversion
  require Logger
  require IEx
  
  @doc """
  Create new account to be managed by connected Ethereum node with password/password confirmation

  ## Example: 

      iex> Ethereum.new_account("p@55w0rd","p@55w0rd")

  """
  @spec new_account(password :: String.t, password_confirmation :: String.t) :: {:ok, String.t} | {:error, String.t}
  def new_account(password, password_confirmation) do
    case Transport.send("personal_newAccount",[password]) do
      {:ok, account_hash} ->
        {:ok, account_hash}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Unlock account account on conected Ethereum node
  
  ## Example:

      iex> Ethereum.unlock_account("0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e", "h4ck3r")
      {:ok, true}

  """
  @spec unlock_account(account :: String.t, password :: String.t) :: {:ok, boolean} | {:error, String.t}
  def unlock_account(account, password) do
    case Transport.send("personal_unlockAccount", [account, password]) do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  @doc """
  Lock account account on conected Ethereum node

  ## Example:
  
      iex> Ethereum.lock_account("0xe55c5bb9d42307e03fb4aa39ccb878c16f6f901e")
      {:ok, true}
  
  """
  @spec lock_account(account :: String.t) :: {:ok, boolean} | {:error, String.t}
  def lock_account(account) do
    case Transport.send("personal_lockAccount", [account]) do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end
  

  @doc """
  Send a transaction usinsg an unlocked account

  ## Example:

      iex> sender = "0x3f156afdb248618892cb5089ba5a5fcac8ee0b01"
      ...> receiver = "0x0f31986d7a0d4f160acd97583e3c3b591dcb5dde"
      ...> amount = 0.5
      ...> password = ""
      ...> Enum.each(1..1000, fn x -> EsprezzoEthereum.send_transaction(sender, receiver, amount, password) end)
      ...> - OR -
      ...> Ethereum.send_transaction(sender, receiver, amount, password)

      {:ok, "88c646f79ecb2b596f6e51f7d5db2abd67c79ff1f554e9c6cd2915f486f34dcb"}
      
  """
  @spec send_transaction(from :: String.t, to :: String, value :: float, password :: String.t) :: {:ok, boolean} | {:error, String.t}
  def send_transaction(from, to, value, password) do
    wei_value = Conversion.to_wei(value, :ether)
    hex_wei_value = "0x" <> Hexate.encode(wei_value)
    Logger.warn "wei value to send: #{wei_value}"
    params = [%{
      "from": from,
      "to": to,
      "gas": "0x186a0", # 100k,
      "gasPrice": "0x9184e72a000", # 10000000000000
      #"gasPrice": "0x48c27395000", # 5000000000000
      #"gasPrice": "0x1840d131aab", # 1666666666666.6667
      "value": hex_wei_value
      }, 
      password
    ]
      
    case Transport.send("personal_sendTransaction", params) do
      {:ok, result} ->
          Logger.warn "SendTransaction result: #{inspect result}"
        {:ok, result}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
end
  