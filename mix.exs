defmodule SvelteRender.MixProject do
  use Mix.Project

  def project do
    [
      app: :svelte_render,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "SvelteRender",
      source_url: "https://github.com/benwoodward/elixir_svelte_render",
      homepage_url: "https://github.com/benwoodward/elixir_svelte_render",
      # The main page in the docs
      docs: [main: "SvelteRender", extras: ["README.md"]]
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
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.21.2", only: :dev},
      {:excoveralls, "~> 0.12.0", only: :test},
      {:nodejs, "~> 1.1"}
    ]
  end

  defp description do
    """
    Renders Svelte components as HTML
    """
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md",
        "priv/server.js",
        "package.json"
      ],
      maintainers: ["Ben Woodward"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/benwoodward/elixir_svelte_render"
      },
      build_tools: ["mix"]
    ]
  end
end
