defmodule Bayesic.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bayesic,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.11", only: :dev},
      {:csv, "~> 2.0", only: :dev},
    ]
  end
end
