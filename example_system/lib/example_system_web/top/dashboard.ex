defmodule ExampleSystemWeb.Top.Dashboard do
  use ExampleSystemWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, top: ExampleSystem.Top.subscribe(), output: "")}
  end

  @impl true
  def handle_event("process_info", %{"pid" => pid}, socket) do
    {:noreply, assign(socket, :output, process_info(:erlang.list_to_pid(~c"#{pid}")))}
  end

  @impl true
  def handle_event("process_kill", %{"pid" => pid}, socket) do
    Process.exit(:erlang.list_to_pid(~c"#{pid}"), :kill)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:top, top}, socket), do: {:noreply, assign(socket, top: top)}

  defp process_info(pid) do
    [current_stacktrace(pid), "\n\n", trace_process(pid)]
  end

  defp trace_process(pid) do
    trace =
      pid
      |> Runtime.trace()
      |> Stream.map(fn {mod, fun, args} -> "#{inspect(mod)}.#{fun}(#{inspect_args(args)})" end)
      |> Enum.join("\n\n")

    [
      "Dynamic trace",
      "------------------",
      trace
    ]
    |> Enum.join("\n")
  end

  defp inspect_args(args),
    do: args |> inspect(limit: 5, pretty: true, width: 30) |> String.replace(~r/^\[/, "") |> String.replace(~r/\]$/, "")

  defp current_stacktrace(pid) do
    case Process.info(pid, :current_stacktrace) do
      nil ->
        ""

      {:current_stacktrace, stacktrace} ->
        [
          "Current stacktrace",
          "------------------"
        ]
        |> Stream.concat(Stream.map(stacktrace, &format_stacktrace_entry/1))
        |> Stream.concat([""])
        |> Enum.join("\n")
    end
  end

  defp format_stacktrace_entry({mod, fun, arity, location}), do: "#{inspect(mod)}.#{fun}/#{arity} #{location(location)}"

  defp location(location) do
    [:file, :line]
    |> Stream.map(&location[&1])
    |> Enum.reject(&is_nil/1)
    |> case do
      [file, line] -> "at #{file}:#{line}"
      _ -> ""
    end
  end
end
