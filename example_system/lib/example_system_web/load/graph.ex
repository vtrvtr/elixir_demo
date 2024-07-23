defmodule ExampleSystemWeb.Load.Graph do
  use ExampleSystemWeb, :live_component

  def graph(assigns) do
    ~H"""
    <svg viewBox={"0 0 #{graph_width() + 150} #{graph_height() + 150}"} height="500" class="chart">
      <style>
        .title { font-size: 30px;}
      </style>

      <g transform="translate(100, 100)">
        <g stroke="black">
          <text class="title" text-anchor="middle" dominant-baseline="central" x="300" y="-50" fill="black">
            <%= @title %>
          </text>
        </g>

        <%= for legend <- @graph.legends do %>
          <g stroke="black">
            <text text-anchor="end" dominant-baseline="central" x="-20" y={y(legend.at)} fill="black">
              <%= legend.title %>
            </text>
          </g>

          <g stroke-width="1" stroke="gray" stroke-dasharray="4">
            <line x1="0" x2={graph_width()} y1={y(legend.at)} y2={y(legend.at)} />
          </g>
        <% end %>

        <g stroke-width="2" stroke="black">
          <line x1="0" x2="0" y1="0" y2={graph_height()} />
          <line x1="0" x2={graph_width()} y1={graph_height()} y2={graph_height()} />
        </g>

        <polyline fill="none" stroke="#0074d9" stroke-width="2" points={data_points(@graph)} />
      </g>
    </svg>
    """
  end

  defp data_points(graph) do
    graph.data_points
    |> Stream.map(&"#{x(&1.x)},#{y(&1.y)}")
    |> Enum.join(" ")
  end

  def x(relative_x), do: min(round(relative_x * graph_width()), graph_width())
  def y(relative_y), do: graph_height() - min(round(relative_y * graph_height()), graph_height())

  def graph_width(), do: 600
  def graph_height(), do: 500

  def highlight_class(a, a), do: "highlight"
  def highlight_class(_, _), do: ""
end
