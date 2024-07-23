defmodule ExampleSystemWeb.Services.Dashboard do
  use ExampleSystemWeb, :live_view

  @impl true
  def render(assigns), do: ExampleSystemWeb.Services.View.render("dashboard.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if socket.connected?, do: :timer.send_interval(100, :refresh_state)
    {:ok, refresh_state(assign(socket, response: nil))}
  end

  @impl Phoenix.LiveView
  def handle_event("add_service", %{"service" => %{"name" => name}}, socket) do
    if name != "", do: ExampleSystem.Service.start_in_cluster(name)
    {:noreply, refresh_state(socket)}
  end

  @impl true
  def handle_event("invoke_" <> name, _params, socket) do
    {:noreply, assign(socket, response: ExampleSystem.Service.invoke(name))}
  end

  @impl true
  def handle_info(:refresh_state, socket), do: {:noreply, refresh_state(socket)}

  defp refresh_state(socket), do: assign(socket, nodes: nodes())

  defp nodes() do
    services =
      Enum.group_by(
        for({name, pid} <- Swarm.registered(), do: %{name: name, node: node(pid)}),
        & &1.node,
        & &1.name
      )

    Node.list([:this, :visible])
    |> Stream.map(&%{name: &1, services: Enum.sort(Map.get(services, &1, []))})
    |> Enum.sort_by(& &1.name)
  end
end
