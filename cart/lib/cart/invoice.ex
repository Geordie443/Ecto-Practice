defmodule Cart.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  # added so that the database can be queried 
  import Ecto.Query

  alias Cart.{Invoice, InvoiceItem, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "invoices" do
    field(:customer, :string)
    field(:amount, :decimal, precision: 12, scale: 2)
    field(:balance, :decimal, precision: 12, scale: 2)
    field(:date, Ecto.Date)
    has_many(:invoice_items, InvoiceItem, on_delete: :delete_all)
    # when invoice is deleted, all associated invoice_items are also

    timestamps
  end

  @fields ~w(customer amount balance date)

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, @fields)
    # customer and date are required
    |> validate_required([:customer, :date])
  end

  def create(params) do
    cs =
      changeset(%Invoice{}, params)
      |> validate_item_count(params)
      |> put_assoc(:invoice_items, get_items(params))

    if cs.valid? do
      Repo.insert(cs)
    else
      cs
    end
  end

  defp get_items(params) do
    items = params[:invoice_items] || params["invoice_items"]
    # items = items_with_prices(params[:invoice_items] || params["invoice_items"])
    Enum.map(items, fn item -> InvoiceItem.changeset(%InvoiceItem{}, item) end)
  end

  defp validate_item_count(cs, params) do
    items = params[:invoice_items] || params["invoice_items"]

    if Enum.count(items) <= 0 do
      add_error(cs, :invoice_items, "Invalid number of items")
    else
      cs
    end
  end

  '''
    # seacrches through the items and finds and sets prices for all of them
  # recieves a list as an arguement
  defp items_with_prices(items) do
    # iterates through all items and only get item_id or the string item_id
    item_ids = Enum.map(items, fn item -> item[:item_id] || item["item_id"] end)
    # finds all items thare are in item_ids and will return a map with the item.id and item:price
    q = from(i in Item, select: %{id: i.id, price: i.price}, where: i.id in ^item_ids)
    # returns a list of maps of id and price
    prices = Repo.all(q)

    # iterates through each item in order to find the price
    Enum.map(items, fn item ->
      item_id = item[:item_id] || item["item_id"]

      %{
        item_id: item_id,
        quantity: item[:quantity] || item["quantity"],
        # produces new list with item id, quantity, and price
        price: Enum.find(prices, fn p -> p[:id] == item_id end)[:price] || 0
      }
    end)
  end
  '''
end
