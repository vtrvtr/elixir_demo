defmodule ExampleSystemWeb.Load.Dashboard do
  use ExampleSystemWeb, :live_view
  import ExampleSystemWeb.Load.Graph

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="loadGrid">
        <.simple_form for={@load} phx-submit="change_load">
          <.input name="load" value={Map.get(@load, :value, 0)} label="Load" />
          <:actions>
            <.button>Save</.button>
          </:actions>
        </.simple_form>
        <div>
          <span phx-click="highlight_memory" class={@highlighted}></span>
        </div>

        <div class="simple-form-container">
          <.simple_form for={@schedulers} phx-submit="change_schedulers" class="flex flex-col space-y-4">
            <.input name="schedulers" value={Map.get(@schedulers, :value, 0)} label="Schedulers" />
            <div class="actions flex space-x-4">
              <.button>Save</.button>
              <.button phx-click="reset" value="reset">Reset</.button>
            </div>
          </.simple_form>
        </div>
      </div>

      <div class="metrics-container grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-2 p-4">
        <div class="metric-card bg-white shadow-lg rounded-lg p-6 flex flex-col items-center justify-center">
          <div class="metric-title text-xl font-semibold mb-2">Jobs</div>
          <div class="metric-value text-3xl font-bold text-blue-600">
            <%= @metrics.load %>
          </div>
          <div class="metric-detail text-sm text-gray-500 mt-2">Memory: <%= @metrics.memory_usage %> MB</div>
        </div>
        <div class="metric-card bg-white shadow-lg rounded-lg p-6 flex flex-col items-center justify-center">
          <div class="metric-title text-xl font-semibold mb-2">Schedulers</div>
          <div class="metric-value text-3xl font-bold text-green-600">
            <%= @metrics.schedulers %>
          </div>
        </div>
      </div>

      <div class="chartsGrid flex justify-center items-center">
        <div class="flex" phx-click="highlight_jobs_graph" class="highlighted">
          <.graph title="successful jobs/sec" , graph={@metrics.jobs_graph} />
        </div>

        <div class="flex" phx-click="highlight_scheduler_graph" class="highlighted">
          <.graph title="Schedulers" , graph={@metrics.scheduler_graph} />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       load: value(LoadControl.load()),
       schedulers: %{"value" => :erlang.system_info(:schedulers_online)},
       metrics: ExampleSystem.Metrics.subscribe(),
       highlighted: nil
     )}
  end

  @impl true
  def handle_event("change_load", %{"load" => load}, socket) do
    with {load, ""} when load >= 0 <- Integer.parse(load) do
      Task.start_link(fn -> LoadControl.change_load(load) end)
      {:noreply, assign(socket, :load, value(load))}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("change_schedulers", %{"schedulers" => schedulers}, socket) do
    with {schedulers, ""} when schedulers > 0 <- Integer.parse(schedulers) do
      Task.start_link(fn -> LoadControl.change_schedulers(schedulers) end)
      {:noreply, assign(socket, :schedulers, value(schedulers))}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    me = self()

    Task.start_link(fn ->
      ExampleSystem.Metrics.subscribe()

      LoadControl.change_load(0)

      fn -> ExampleSystem.Metrics.await_next() end
      |> Stream.repeatedly()
      |> Stream.drop_while(&(&1.jobs_rate > 0))
      |> Enum.take(1)

      LoadControl.change_schedulers(1)
      Process.sleep(1000)

      send(me, :clear_history)
    end)

    {:noreply, socket}
  end

  def handle_event("highlight_" <> what, _params, socket) do
    highlighted = if socket.assigns.highlighted == what, do: nil, else: what
    {:noreply, assign(socket, :highlighted, highlighted)}
  end

  @impl true
  def handle_info({:metrics, metrics}, socket), do: {:noreply, assign(socket, :metrics, metrics)}

  @impl true
  def handle_info(:clear_history, socket) do
    ExampleSystem.Metrics.clear_history()

    {:noreply,
     assign(socket,
       load: changeset(LoadControl.load()),
       schedulers: changeset(:erlang.system_info(:schedulers_online))
     )}
  end

  defp changeset(value), do: Ecto.Changeset.cast({%{}, %{value: :integer}}, %{value: value}, [:value])

  defp value(value), do: %{"value" => value}
end
