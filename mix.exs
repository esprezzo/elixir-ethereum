defmodule Ethereum.Mixfile do
  use Mix.Project

  def project do
    [app: :ethereum,
     version: "0.1.1",
     elixir: "~> 1.12",
     package: package(),
     description: description(),
     name: "Ethereum",
     source_url: "https://github.com/esprezzo/elixir-ethereum",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Ethereum.Application, []}]
  end

  defp package do
    # These are the default files included in the package
    [
      name: :ethereum,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Alan Wilhelm"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/esprezzo/elixir-ethereum"}
    ]
  end


  defp description do
     """
     This library exists to present a convenient interface to control a full Ethereum node from Elixir, abstracting away the need to deal with the JSON-RPC API directly.
     """
  end

  defp deps do
    [
      {:ex_keccak, "~> 0.2.0"},
      {:tesla, "~> 1.4.0"},
      {:ex_abi, "~> 0.5.5"},
      # optional, but recommended adapter
      {:hackney, "~> 1.17.0"},
      # {:jason, ">= 1.0.0"},
      {:hexate,  ">= 0.6.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
 		  {:ex_doc, "~> 0.14", only: :dev}
   ]
  end
end
