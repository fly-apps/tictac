defmodule Tictac.Square do
  @moduledoc """
  Struct that represents the state of a single board square.
  """
  alias __MODULE__

  defstruct name: nil, letter: nil

  @type t :: %Square{
    name: nil | atom(),
    letter: nil | String.t()
  }

  @doc """
  Build and return a board square. Provide the name.
  """
  @spec build(name :: atom, letter :: nil | String.t()) :: t()
  def build(name, letter \\ nil) do
    %Square{name: name, letter: letter}
  end

  @doc """
  Return if the square is open. True if no player has claimed the square. False
  if a player occupies it.

  ## Example

      iex> is_open?(%Tictac.Square{name: :sq11, letter: nil})
      true

      iex> is_open?(%Tictac.Square{name: :sq11, letter: "O"})
      false

      iex> is_open?(%Tictac.Square{name: :sq11, letter: "X"})
      false
  """
  @spec is_open?(t()) :: boolean()
  def is_open?(%Square{letter: nil}), do: true
  def is_open?(%Square{}), do: false
end
