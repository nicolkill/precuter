defmodule Precuter.MixProject do
  use Mix.Project

  def project do
    [
      app: :precuter,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "precuter",
      description: "Another decorator library for Elixir.",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      source_url: "https://github.com/nicolkill/precuter",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "precuter",
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nicolkill/precuter"}
    ]
  end
end
