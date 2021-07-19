defmodule OptimusHash.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :optimus_hash,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "ID hashing based on Knuth's multiplicative hashing algorithm",
      package: package(),

      # Docs
      name: "OptimusHash",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [{:logger, :optional}, {:eex, :optional}, {:crypto, :optional}]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      maintainers: ["smartvokat"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/smartvokat/optimus_hash"},
      files: [".formatter.exs", "mix.exs", "README.md", "LICENSE", "lib"]
    ]
  end

  def docs do
    [
      main: "OptimusHash",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/optimus_hash",
      source_url: "https://github.com/smartvokat/optimus_hash",
      extras: [
        "guides/integrations/absinthe-relay.md"
      ],
      groups_for_extras: [
        Integrations: ~r/guides\/integrations\/.*/
      ]
    ]
  end
end
