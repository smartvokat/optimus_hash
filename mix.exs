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

      # Docs
      name: "OptimusHash",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Docs
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
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
