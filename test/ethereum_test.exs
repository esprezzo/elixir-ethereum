
defmodule EthereumTest do
  use ExUnit.Case
  require IEx

  doctest Ethereum

  # TODO: cover all non-network features
  describe "hexutils module" do

    test "to_hex/1 works on integer" do
      assert Ethereum.to_hex(1440002) == "0x15f902"
    end

  end
  
end
