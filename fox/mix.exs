defmodule Fox.MixProject do
  use Mix.Project

  def project do
    [
      app: :fox,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # postgrex and ecto are used in this app
      extra_applications: [:logger, :ecto, :postgrex],
      mod: {Fox.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:postgrex, ">= 0.11.1"},
      {:ecto, "~> 2.0"}
    ]
  end
end
