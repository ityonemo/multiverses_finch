defmodule MultiversesFinch.MixProject do
  use Mix.Project

  @finch_version "0.3.0"
  @version "0.1.0"

  def project do
    [
      app: :multiverses_finch,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/_support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # parent library that's being cloned
      {:finch, "~> #{@finch_version}"},
      {:multiverses, "~> 0.5.0", runtime: false},

      # for testing
      {:bypass, "~> 1.0", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test},
      {:mox, "~> 0.5.2", only: :test}
    ]
  end
end
