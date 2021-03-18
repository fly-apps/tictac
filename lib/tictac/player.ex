defmodule Tictac.Player do
  @moduledoc """
  Player struct.
  """
  alias __MODULE__

  defstruct name: nil, letter: nil

  @type t :: %Player{
          name: nil | String.t(),
          letter: nil | String.t()
        }
end
