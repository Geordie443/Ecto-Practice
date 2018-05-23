defmodule Cart.InvoiceItem do
  use Ecto.Schema
  import Ecto.Changeset

  # primary key auto generates
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "invoice_items" do
    # sets up relationship with Cart.Invoice Changeset
    belongs_to(:invoice, Cart.Invoice, type: :binary_id)
    # sets relationship with items table
    belongs_to(:item, Cart.Item, type: :binary_id)
    # same as schema for item
    field(:quantity, :decimal, precision: 12, scale: 2)
    field(:price, :decimal, precision: 12, scale: 2)
    field(:subtotal, :decimal, precision: 12, scale: 2)

    timestamps
  end

  @fields ~w(item_id price quantity)
  # @zero is being made into a constant that can be used in this module 
  @zero Decimal.new(0)

  def changeset(data, params \\ %{}) do
    data
    # organizes fields that will be cast rather than listim them all inside the changeset
    |> cast(params, @fields)
    |> validate_required([:item_id, :price, :quantity])
    |> validate_number(:price, greater_than_or_equal_to: @zero)
    |> validate_number(:quantity, greater_than_or_equal_to: @zero)
    # checks for foreign key contraint and generates a message instead of an exception
    |> foreign_key_constraint(:invoice_id, message: "Select a valid invoice")
    |> foreign_key_constraint(:item_id, message: "Select a valid item")
    # calculates subtotal as shown underneath
    |> set_subtotal
  end

  # definition for set subtotal
  def set_subtotal(cs) do
    case {cs.changes[:price] || cs.data.price, cs.changes[:quantity] || cs.data.quantity} do
      # if just price
      {_price, nil} ->
        # nothing happens
        cs

      # if just quantity
      {nil, _quantity} ->
        # nothing happens
        cs

      # if both
      {price, quantity} ->
        # subtotal set to price * quantity
        put_change(cs, :subtotal, Decimal.mult(price, quantity))
    end
  end
end
