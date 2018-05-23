defmodule Cart do
  use Application

  def start(_type, _arg) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Cart.Repo, [])
    ]

    options = [strategy: :one_for_one, name: Cart.Supervisor]
    Supervisor.start_link(children, options)
  end

  @moduledoc """
  Documentation for Cart.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cart.hello
      :world

  """
end
