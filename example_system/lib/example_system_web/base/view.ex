defmodule ExampleSystemWeb.Base.View.Old do
  defmacro __using__(opts) do
    quote do
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers
      import ExampleSystemWeb.Router
      import ExampleSystemWeb.ErrorHelpers
      import ExampleSystemWeb.CoreComponents

      use Phoenix.VerifiedRoutes,
        endpoint: ExampleSystemWeb.Endpoint,
        router: ExampleSystemWeb.Router,
        statics: ExampleSystemWeb.Endpoint.static_paths()

      use Phoenix.View,
          Keyword.merge(
            [root: "lib/example_system_web/templates", namespace: ExampleSystemWeb],
            unquote(opts)
          )

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
    end
  end
end
