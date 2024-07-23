defmodule ExampleSystem.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
