defmodule FoxTest do
  use ExUnit.Case
  doctest Fox

  test "greets the world" do
    assert Fox.hello() == :world
  end
end
