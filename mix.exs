defmodule PhxDiff.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_diff,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:boundary] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        ci: :test
      ],
      releases: releases(),
      default_release: :phx_diff,
      dialyzer: dialyzer(System.get_env()),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PhxDiff.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:git_diff, github: "mononym/git_diff"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:ecto, "~> 3.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.4"},
      {:logster, "~> 1.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:honeybadger, "~> 0.22.0"},
      # The following are dependencies are needed for OpenTelemetry
      {:tls_certificate_check, "~> 1.11"},
      {:opentelemetry_exporter, "~> 1.6"},
      # Holding back until https://github.com/open-telemetry/opentelemetry-erlang/pull/717 is released
      {:opentelemetry, "~> 1.3.0"},
      {:opentelemetry_api, "~> 1.2.0"},
      {:opentelemetry_phoenix, "~> 1.2"},
      {:opentelemetry_liveview, "~> 1.0.0-rc.4"},
      {:boundary, "~> 0.9", runtime: false},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3.0", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {
        :font_awesome,
        github: "FortAwesome/Font-Awesome",
        tag: "6.7.2",
        sparse: "svgs",
        app: false,
        compile: false,
        depth: 1
      },
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 1.2", only: :test, runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      ci: [
        "compile --warnings-as-errors --force",
        "format --check-formatted",
        "test --raise --all-warnings --warnings-as-errors",
        "credo --strict --all",
        "dialyzer"
      ],
      setup: ["deps.get", "assets.setup"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd --cd assets yarn install"
      ],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end

  # Environment specific dialyzer config
  defp dialyzer(%{"CI" => "true"}) do
    [
      plt_core_path: ".dialyzer/core",
      plt_local_path: ".dialyzer/local"
    ] ++ dialyzer()
  end

  defp dialyzer(_), do: dialyzer()

  # Common dialyzer config
  defp dialyzer do
    [plt_add_apps: [:mix, :ex_unit]]
  end

  defp docs do
    [
      formatters: ["html"],
      filter_modules: ~r/^Elixir\.PhxDiff(?!Web)/
    ]
  end

  defp releases do
    [
      phx_diff: [
        include_executables_for: [:unix],
        applications: [
          runtime_tools: :permanent,
          phx_diff: :permanent,
          opentelemetry_exporter: :permanent,
          opentelemetry: :temporary
        ]
      ]
    ]
  end
end
