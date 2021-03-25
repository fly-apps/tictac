defmodule Tictac.Fixtures do
  @moduledoc """
  This module defines test helpers for creating entities.
  """
  alias Tictac.Player

  @spec fixture(type :: atom(), attrs :: map()) :: struct()
  def fixture(type, attrs \\ %{})

  def fixture(:player, attrs) do
    %Player{
      id: Ecto.UUID.generate(),
      name: Map.get(attrs, :name, Enum.random(["Player", "Tom", "Sally", "Herman", "Jessica"])),
      letter: Map.get(attrs, :letter, Enum.random(["X", "O"]))
    }
  end
end
