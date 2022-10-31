defmodule BigBrother.MixProject do
  use Mix.Project

  @source_url "https://github.com/Terminus-Systems/big_brother"

  def project do
    [
      app: :big_brother_ex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "BigBrother",
      source_url: @source_url,
      docs: [
        main: "readme", # The main page in the docs
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  defp description do
    "Elixir library capable of watching and recompiling/reloading files at runtime."
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:fs, "~> 8.6"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
    maintainers: ["Calancea Daniel"],
    licenses: ["Apache-2.0"],
    links: %{"GitHub" => @source_url},
    files:
        ~w(.formatter.exs mix.exs README.md lib)
    ]
  end
end
