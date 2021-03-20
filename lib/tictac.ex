defmodule Tictac do
  @moduledoc """
  Tictac keeps the contexts that define your domain
  and business logic.
  """
  alias Tictac.Player
  alias Tictac.GameState

  @doc """
  Setup a new game. A game starts with a single player joining.
  """
  @spec new_game(Player.t()) :: GameState.t()
  def new_game(%Player{} = player) do
    GameState.new(player)
  end

  @doc """
  Join a started game. Returns error if not found.
  """
  @spec join_game(game_server_name :: String.t(), Player.t()) :: :ok | {:error, String.t()}
  def join_game(%Player{} = player, game_server_name) do
    {:error, "Game server not found"}
  end
end
