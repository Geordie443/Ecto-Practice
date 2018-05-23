# name of overall mix project and name of elixir code
defmodule Cart.Item do
  # inject code into the changeset using this
  use Ecto.Schema
  # import functionality from Ecto.Changeset
  import Ecto.Changeset
  import Ecto.Query

  # allows use of InvoiceItem changeset
  alias Cart.InvoiceItem

  # specifies that the primary key will be auto-generated
  @primary_key {:id, :binary_id, autogenerate: true}
  # define the schema and inside this block each field and relationship is defined
  schema "items" do
    field(:name, :string)
    field(:price, :decimal, precision: 12, scale: 2)
    # relationship between Item and InvoiceItem
    has_many(:invoice_items, InvoiceItem)
    # sets the inserted_at and updated_at fields
    timestamps()
  end

  @fields ~w(name price)

  # recieves an elixir struct with params that will be piped through different functions. // %{} uses an empty map if no data is provided
  def changeset(data, params \\ %{}) do
    data
    # casts the values into the correct type
    |> cast(params, @fields)

    # validates that the fields are present
    |> validate_required([:name, :price])

    # validates that the price is greater than or equal to 0
    |> validate_number(:price, greater_than_or_equal_to: Decimal.new(0))
  end
end
