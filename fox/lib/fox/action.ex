defmodule Fox.Action do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "action" do
    # defaults values can be included so that when they are not provided, they auto fill to something
    field(:name, :string, size: 20, default: "shine")
    field(:percent, :integer, default: 1000)
    field(:frames, :integer, default: 1)

    # field(:disjoint, :string)   #if this is included, the repo will have an error since the table does not have this field
    timestamps()
  end

  @fields ~w(name percent frames)

  # basic changeset with only name validation and empty default
  def changeset_one(data, params \\ %{}) do
    data
    |> cast(params, @fields)
    |> validate_required([:name])
  end

  # second changeset with a few more functions
  def changeset_two(data, params \\ %{}) do
    data
    |> cast(params, [:name, :percent, :frames])
    |> validate_required([:name, :percent, :frames])
  end
end
