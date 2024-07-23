import Config

config :example_system, ExampleSystemWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  http: [transport_options: [num_acceptors: 5]],
  # watchers: [
  #   node: [
  #     "node_modules/webpack/bin/webpack.js",
  #     "--mode",
  #     "development",
  #     "--watch",
  #     cd: Path.expand("../assets", __DIR__)
  #   ]
  # ],
  debug_errors: true,
  secret_key_base: "ypvEr9UdE+OLgpd08/DJY+q1iG1i/7/v69vFEbvb9rtgcnyH9+GUdrjVrAK1w5RW",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :example_system, ExampleSystemWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/example_system_web/.*\.(eex|leex|ex)$}
    ]
  ]

config :logger, :console, level: :debug, format: "[$level] foo $message\n"

config :phoenix, :stacktrace_depth, 20
