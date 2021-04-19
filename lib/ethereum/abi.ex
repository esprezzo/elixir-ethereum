defmodule Ethereum.ABI do
  require IEx
  require Logger
  @spec load_abi(binary()) :: list() | {:error, atom()}
  @doc "Loads the abi at the file path and reformats it to a map"
  def load_abi(file_path) do
    file = File.read(Path.join(System.cwd(), file_path))
    case file do
      {:ok, abi} ->
       __MODULE__.reformat_abi(Jason.decode!(abi, %{}))
      err -> err
    end
  end

  @spec reformat_abi(list()) :: map()
  @doc "Reformats abi from list to map with event and function names as keys"
  def reformat_abi(abi) do
    abi
    |> Enum.map(&map_abi/1)
    |> Map.new()
  end

  @spec encode_event(binary()) :: binary()
  @doc "Encodes event based on signature"
  def encode_event(signature) do
    with {:ok, hash} <- ExKeccak.hash_256(signature),
         {:ok, encoded} <- Base.encode16(hash, case: :lower),
        do: {:ok, encoded}
  end

  @spec encode_data(binary(), list()) :: binary()
  @doc "Encodes data into Ethereum hex string based on types signature"
  def encode_data(types_signature, data) do
    ABI.TypeEncoder.encode_raw(
      [List.to_tuple(data)],
      ABI.FunctionSelector.decode_raw(types_signature)
    )
  end

  @spec encode_options(map(), list()) :: map()
  @doc "Encodes list of options and returns them as a map"
  def encode_options(options, keys) do
    keys
    |> Enum.filter(fn option ->
      Map.has_key?(options, option)
    end)
    |> Enum.map(fn option ->
      {option, encode_option(options[option])}
    end)
    |> Enum.into(%{})
  end

  @spec encode_option(integer()) :: binary()
  @doc "Encodes options into Ethereum JSON RPC hex string"
  def encode_option(0), do: "0x0"

  def encode_option(nil), do: nil

  def encode_option(value) do
    "0x" <>
      (value
       |> :binary.encode_unsigned()
       |> Base.encode16(case: :lower)
       |> String.trim_leading("0"))
  end
  
  @spec encode_method_call(map(), binary(), list()) :: binary()
  @doc "Encodes data and appends it to the encoded method id"
  def encode_method_call(abi, name, input) do
    encoded_method_call =
      method_signature(abi, name) <> encode_data(types_signature(abi, name), input)

    encoded_method_call |> Base.encode16(case: :lower)
  end

  @doc """

    Generates function sig if you know the name of the function

  """
  @spec method_signature(map(), binary()) :: binary()
  @doc "Returns the 4 character method id based on the hash of the method signature"
  def method_signature(abi, name) do
    if abi[name] do
      {:ok, input_signature} = "#{name}#{types_signature(abi, name)}" |> ExKeccak.hash_256()
      
      # Take first four bytes
      <<init::binary-size(4), _rest::binary>> = input_signature
      init
    else
      raise "#{name} method not found in the given abi"
    end
  end

  @doc """
    Returns the type signature of a given function given the name
  """
  @spec types_signature(map(), binary()) :: binary()
  def types_signature(abi, name) do
    input_types = Enum.map(abi[name]["inputs"], fn x -> x["type"] end)
    types_signature = Enum.join(["(", Enum.join(input_types, ","), ")"])
    types_signature
  end
  
  # ABI mapper
  defp map_abi(x) do
    n = x["name"]
    t = x["type"]
    # Logger.warn "(#{n},#{t})"
    # Logger.warn "---------------------------------------"
    case {x["name"], x["type"]} do
      {nil, "constructor"} -> {:constructor, x}
      {nil, "fallback"} -> {:fallback, x}
      {name, _} -> {name, x}
      x -> IEx.pry
    end
  end

  @spec decode_data(binary(), binary()) :: any()
  @doc "Decodes data based on given type signature"
  def decode_data(types_signature, data) do
    case types_signature do
      "(address)" -> decode_address(data)
      other -> 
        {:ok, trim_data} = String.slice(data, 2..String.length(data)) |> Base.decode16(case: :lower)
        ABI.decode(types_signature, trim_data) |> List.first()
    end
  end

  def is_padded?(a) do
    String.length(a) >= 42
  end
  ###
  # PM/guard for binary?
  # basically just an issue
  # 
  def decode_address(data) do
    len = String.length(data)
    res = 
      if __MODULE__.is_padded?(data) do
        unpadded = String.slice(data, 26..String.length(data))
        # IEx.pry
        # inted = Hexate.to_integer(unhexed)
        # rehexed = Hexate.encode(inted)
        zeroexd = "0x" <> unpadded
      else
        IEx.pry
        data
      end
  end
  def decode_address_binary(data) do
    rehexed = Hexate.encode(data)
    zeroexd = "0x" <> rehexed
  end

  @spec decode_output(map(), binary(), binary()) :: list()
  @doc "Decodes output based on specified functions return signature"
  def decode_output(abid, name, output) do
    output = 
      case output do
        nil -> [0]
        "0x" -> [0]
        x -> 
          {:ok, trim_output} =
            String.slice(output, 2..String.length(output)) |> Base.decode16(case: :lower)

          atom_key = String.to_atom(name)
          output_types = Enum.map(abid[name]["outputs"], fn x -> x["type"] end)

          types_signature = Enum.join(["(", Enum.join(output_types, ","), ")"])
          # output_signature = "#{name}(#{types_signature})" # FUCKED OFF PARENS
         
          output_signature = "#{name}#{types_signature}" 
          outputs =
            ABI.decode(output_signature, trim_output)
            # |> List.first() ?
            # |> Tuple.to_list() ?
          outputs
      end
    
  end


  @doc """
  :binary.decode_unsigned(<<4, 3, 2, 1>>, :big)
  https://thoughtbot.com/blog/do-you-break-your-elixir-eggs-on-the-big-end-or-the-little-end
  takes abi file now
  """
  def decode_input(abi_file, input_data) do
    << function_sig::binary-size(2), split_data::binary >> = input_data
    short_sig = String.slice(function_sig, 0, 10)
    # signature_hex_map = __MODULE__.map_signatures(abi)
    spec = 
      File.read!(abi_file)
        |> Jason.decode!
        |> ABI.parse_specification
        |> ABI.find_and_decode(split_data |> Base.decode16!(case: :lower))   
  end

  def map_signatures(abi_data) do
    keys = Map.keys(abi_data)
    Enum.reduce(keys, %{}, fn method_name, acc -> 
      i = Map.get(abi_data, method_name)
      input_types = Enum.map(abi_data[method_name]["inputs"], fn x -> x["type"] end)
      types_signature = Enum.join(["(", Enum.join(input_types, ","), ")"])
      input_signature = "#{method_name}#{types_signature}"
      {:ok, hash} = ExKeccak.hash_256(input_signature)
      hex_hash = Hexate.encode(hash)
      input_sig = String.slice(hex_hash, 0,8)
      k = "0x#{input_sig}"
      Logger.warn ">>-----> TRUNCATED HEX HASH Method name: #{input_signature} // #{k}"
      Map.put(acc, k, input_signature)
    end)
  end

  #  def encode_event(signature) do
  #     with {:ok, hash} <- ExKeccak.hash_256(signature),
  #          {:ok, encoded} <- Base.encode16(hash, case: :lower),
  #         do: {:ok, encoded}
  #  end

  @spec keys_to_decimal(map(), list()) :: map()
  def keys_to_decimal(map, keys) do
    for k <- keys, into: %{}, do: {k, map |> Map.get(k) |> Ethereum.hex_to_decimal()}
  end

end