defmodule Bayesic.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bayesic,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      package: package(),
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
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      maintainers: ["Michael Ries"],
      licenses: ["MIT"],
      description: """
      A probablistic string matcher similar to Naive Bayes, but optimized for many classes with small documents
      """,
      links: %{
        github: "https://github.com/mmmries/bayesic",
        docs: "http://hexdocs.pm/bayesic"
      },
    ]
  end
end
