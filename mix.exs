defmodule Bosun.MixProject do
  use Mix.Project

  @source_url "https://github.com/themusicman/bosun"
  @version "1.0.0"

  def project do
    [
      app: :bosun,
      version: @version,
      elixir: "~> 1.13",
      consolidate_protocols: Mix.env() != :test,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def package do
    [
      description: "Little bit of help defining authorization policies",
      maintainers: ["Thomas Brewer"],
      contributors: ["Thomas Brewer"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url
      }
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Readme"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      api_reference: false,
      formatters: ["html"]
    ]
  end
end
