defmodule ExampleSystem.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExampleSystem.Items` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        value: 42
      })
      |> ExampleSystem.Items.create_item()

    item
  end
end
