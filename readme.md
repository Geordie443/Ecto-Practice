Notes While following this tutorial:
	https://www.toptal.com/elixir/meet-ecto-database-wrapper-for-elixir

Overview:
	Ecto.Repo
		Defines repositories that are wrappers around data storage. Can insert, create, delete, and query a repo.
	Ecto.Schema
		Used to map any data source into elixir struct
	Ecto.Changeset
		Provide a way for developers to filter and cast external parameters as well as track and validate changes before they are applied to data
	Ecto.Query
		DSL-like SQL query for retrieving info from a repository

Install and Config:
	create mix app: $ mix new cart --sup
		this creates a directory called cart with all project files
	--sup option provides supervisor tree which provides connection to the database
	go to cart directory and replace contents of mix.exs
		add applications :postgrex and :ecto to defp deps do so that they can be used inside the application
	$ mix deps.get (while in cart directory)
		this installs all dependencies and creates a mix.lock file 

Ecto.Repo:
	Define repo in config/config.exs
		multiple repos can be defined in the config file, as multiple DBs can be connected to
		the following config line tells ecto which repo we use
			config :cart, ecto_repos: [Cart.Repo]
		run fullowing line to generate repo:
			mix ecto.gen.repo
				this repo generation tells you to add your repo to your supervision tree and list of ecto repos in your configuration files
	edit lib/cart.ex
		define supervisor(Cart.Repo, []) and add it to the children list
		the children are supervised with strategy :one_for_one, meaning that if one of the supervised processes fails, the supervisor will restart only that process into is default state
	lib/cart/repo.ex already has the Repo for the application
	config/config.exs must be edited
		set the username and password to "postgres" so that the ecto adapter for postgres works
	once the database config is complete, generate it by running the following:
		mix ecto.create

Building an Invoice with Inline Terms:
	this application will use a simple invoicing tool to be used by changesets
		a table "invoices" and a table "items" will both hold many "invoice_items"
		the type for some of the data is UUID to help obfuscate routes incase you want to expose the app over an API

Ecto.Migration
	migrations are files that are used to modify the database schema
	Ecto.Migration gives you methods to create tables, add indexes, create constraints, etc
	use the following line to create a migration script for the first table
		$ mix ecto.gen.migrate create_invoices
	open the newly generated migrations file in /priv/repo/migrations and modify its contents 
	Inside the def change method, the schema is defined. 
		the :invoices table is created, with no primary key
		other fields are also added
		timestamps method is added so that it can generate the time the record was inserted at and updated
		$ mix ecto.migrate creates the table invoice with all the defined fields
	Now, the items table must be created in the same way the invoices table was
		$ mix ecto.gen.migration create_items
		edit the generated migration script so that create_table is added under def change do
			the table is named :items with primary_key: false
			fields such as :id, :name, and :price are added. timestamps method also added
		$ mix ecto.migrate will create the new table
	Finally, the invoice_items table. Same way as the other two
		mix ecto.gen.migration create_invoice_items
		there is a new field in this table, the following lines add the new field:
			add :invoice_id, references(:invoices, type: :uuid, null: false)
			add :item_id, references(:items, type: :uuid, null: false)
			the invoice_id field has a contraint in the database that references the invoice table, the item_id field refernces item
		there is also 2 new index being created by the following lines:
    		create index(:invoice_items, [:invoice_id])
    		create index(:invoice_items, [:item_id])
    		the former creates the index: invoice_items_invoice_id_index

Ecto.Schema and Ecto.Changeset:
	create the most simple changeset item by creating lib/cart/item.ex
	this is a new file to be created from scratch	
	so that the code in this file can easily be used, we will make it into a defmodule that can be utilized elsewhere

Ecto.Schema:
	cart/lib/cart/item.ex is heavily commented so that it is easier to understand how the schema is built

Ecto.Changeset:
	the changeset for cart/lib/cart/{item,invoice,invoice_item}.ex is commented in the document 
	Working with the changeset in iex:
		iex -S mix
			 loads the console
		iex(0)> item = Cart.Item.changeset(%Cart.Item{}, %{name: "Paper", price: "2.5"})
			will return an Ecto.Changeset that is set to item
		iex(1)> item = Cart.Repo.insert!(item)
			inserts the item in the Repo for Cart, the metadata for inserting into the repo will appear 
		iex(3)> item2 = Cart.Item.changeset(%Cart.Item{price: Decimal.new(20)}, %{name: "Scissors"}) 
			alternate method for entering an item into the changeset
		iex(4)> invalid_item = Cart.Item.changeset(%Cart.Item{}, %{name: "Scissors", price: -1.5})
			the changeset in this case will validate to be false since the price did not meet the criteria of being greater than 0 
		------------------------------------------------------------------------------------------------
	Changesets and Enum map
		iex -S mix
		iex(0)> item_ids = Enum.map(Cart.Repo.all(Cart.Item), fn(item)-> item.id end)
			Enum.map gets the item.id of each item via fn(item) -> item.id end. Each item was recieved through Cart.Repo.all(Cart.Item)
		iex(1)> {id1, id2} = {Enum.at(item_ids, 0), Enum.at(item_ids, 1) }
			id1 and id2 are assigned with the first and second item_ids
		iex(2)> inv_items = [%{item_id: id1, price: 2.5, quantity: 2},
							%{item_id: id2, price: 20, quantity: 1}]
			inv_items is a list of 2 maps. Each map contains item with id assigned at id2/id2, a price, and a quantity
		iex(3)> {:ok, inv} = Cart.Invoice.create(%{customer: "James Brown", date: Ecto.Date.utc,
							 invoice_items: inv_items})
			creates an invoice for James brown containing the list of invoice items making the overall structure: Invoice contains invoice_items which is a list of items
		iex(4)> alias Cart.{Repo, Invoice}
			Cart.Repo and Cart.Invoice must be aliased in iex so that modules from them can be used
		iex(5)> Repo.all(Invoice)
			Returns the invoice for "James Brown" based on the schema
		iex(6)> Repo.all(Invoice) |> Repo.preload(:invoice_items)
			Will return the invoice as well as the list of invoice_items within in the invoice

Ecto.Query:
	by using Ecto.Query, queries can be directly made to the database to get information
	iex(1)> alias Cart.{Repo, Item, Invoice, InvoiceItem}
		aliasing all necessary Modules in Cart
	Before querying can be done, items must be added into the Repo
		Example of item being added to repo:
		iex(2)> Repo.insert(%Item{name: "Chocolates", price: Decimal.new("5")})
	After adding some more items, a query can be executed to check if there are any repeated items
		iex(7)> import Ecto.Query
			import Ecto.Query so it can be used
		iex(8)> q = from(i in Item, select: %{name: i.name, count: count(i.name)}, group_by: i.name)
			define q to be a particular query that selects items by name and counts how many times that same name appears, grouping allows names to not be repeated
		iex(9)> Repo.all(q)	
			query the wholle repo by using this command
		The query returns a list of maps that include the count and the name  of each item in the repo
	Creating a map to access items
		iex(10)> l =  Repo.all(from(i in Item, select: {i.name, i.id}))
			creating a list of all items in the repo set to be maps with name and id
		iex(11)> items = for {k, v} <- l, into: %{}, do: {k, v}
			from the list, comprehension is used to create the map:
				for {k, v} <- l,
					k is set to i.name and v is set to i.id from l
				into: %{},
				 	these values will be placed into a map, [] instead of %{} would place in a list
				do: {k, v}
					the value is mapped to the key using => operator
			The final product of the comprehension is a map of key value pairs with name as the key and id as the value
		iex(12)> line_items = [%{item_id: items["Chocolates"], quantity: 2}]
			produces: [%{item_id: "b5d15409-0c9c-4b43-9aa8-467020a1d4e6", quantity: 2}]
				items["Chocolate"] will produce the id for chocolate and not the name since the value was mapped to the name in a key value pair

Inserting More Invoices: I STOPPED AT THIS PART FOR NOW BECAUSE IT WAS BEING PROBLEMATIC
	iex(0)> alias Cart.{Repo, Item, Invoice, InvoiceItem}
	iex(1)> Repo.delete_all(InvoiceItem); Repo.delete_all(Invoice)
		by running these commands, all the invoice items and invoices are deleted from the repo in order to achieve a blank slate



					











