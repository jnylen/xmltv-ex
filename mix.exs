defmodule Xmltv.MixProject do
  use Mix.Project

  @name :xmltv
  @version "0.3.0"
  @deps [
    {:timex, "~> 3.4"},
    {:exprintf, "~> 0.2.1"},
    {:xml_builder, "~> 2.1.1"},
    {:vex, "~> 0.8.0"}
  ]

  def project do
    [
      app: @name,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: @deps
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
