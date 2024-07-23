defmodule ExampleSystemWeb.Math.Sum do
  use ExampleSystemWeb, :live_view
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="sumForm">
      <.simple_form for={@data} phx-submit="submit">
        <.input name="value" type="text" value={Map.get(@data, :value, "")} />
        <:actions>
          <.button>Submit</.button>
        </:actions>
      </.simple_form>
      <br />

      <div class="container mx-auto p-4">
        <div class="max-w-lg mx-auto">
          <%= for operation <- @operations do %>
            <div class="bg-gray-800 shadow-lg rounded-lg overflow-hidden mb-4">
              <div class="px-6 py-4">
                <div class="result flex items-center justify-center bg-gray-700 rounded-lg p-4">
                  <span class="text-xl font-semibold text-gray-300">∑(1..</span>
                  <span class="text-3xl font-bold text-blue-400"><%= operation.input %></span>
                  <span class="text-xl font-semibold text-gray-300">) = </span>
                  <%= if operation.result == :error do %>
                    <span class="text-3xl font-bold text-red-400">Error</span>
                  <% else %>
                    <span class="text-3xl font-bold text-green-400"><%= operation.result %></span>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_parms, _session, socket), do: {:ok, assign(socket, operations: [], data: blank_data())}

  @impl true
  def handle_event("submit", %{"value" => value}, socket) do
    {:noreply, start_sum(socket, value)}
  end

  @impl true
  def handle_info({:sum, pid, sum}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, sum))}

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, :error))}

  defp start_sum(socket, str_input) do
    operation =
      case Integer.parse(str_input) do
        :error -> %{pid: nil, input: str_input, result: "invalid input"}
        {_input, remaining} when byte_size(remaining) > 0 -> %{pid: nil, input: str_input, result: "invalid input"}
        # {input, ""} when input <= 0 -> %{pid: nil, input: input, result: "invalid input"}
        {input, ""} -> do_start_sum(input)
      end

    socket |> update(:operations, &[operation | &1]) |> assign(:data, blank_data())
  end

  defp do_start_sum(input) do
    {:ok, pid} = ExampleSystem.Math.sum(input)
    %{pid: pid, input: input, result: :calculating}
  end

  defp set_result(operations, pid, result) do
    case Enum.split_with(operations, &match?(%{pid: ^pid, result: :calculating}, &1)) do
      {[operation], rest} -> [%{operation | result: result} | rest]
      _other -> operations
    end
  end

  defp blank_data() do
    %{"value" => ""}
  end
end
