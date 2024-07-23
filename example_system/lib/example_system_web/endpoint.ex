defmodule ExampleSystemWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :example_system

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :example_system
  end

  plug Plug.RequestId
  plug Plug.Logger

  @session_options [
    store: :cookie,
    key: "_example_system_key",
    signing_salt: "0n9cNL8H",
    same_site: "Lax"
  ]


  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session, @session_options

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :example_system,
    gzip: false,
    only: ExampleSystemWeb.static_paths()

  plug ExampleSystemWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config), do: {:ok, put_in(config[:http][:port], port())}

  defp port() do
    if node() == :"node2@127.0.0.1", do: 4001, else: 4000
  end
end
