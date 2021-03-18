defmodule Tictac.GameState do
  @moduledoc """
  Model the game state for a tic-tac-toe game.
  """
  alias Tictac.Square
  alias Tictac.Player
  alias __MODULE__

  # The board's squares are addressible using an atom like this: `:sq11` for
  # "Square: Row 1, Column 1". Ths goes through `:sq33` for "Square: Row 3,
  # Column 3".
  defstruct players: [],
            player_turn: nil,
            board: [
              # Row 1
              Square.build(:sq11),
              Square.build(:sq12),
              Square.build(:sq13),
              # Row 2
              Square.build(:sq21),
              Square.build(:sq22),
              Square.build(:sq23),
              # Row 3
              Square.build(:sq31),
              Square.build(:sq32),
              Square.build(:sq33)
            ]

  @type t :: %GameState{
          players: [Player.t()],
          player_turn: nil | integer(),
          board: [Square.t()]
        }

  @doc """
  Check to see if the player won. Return a tuple of the winning squares if the they won. If no win found, returns `:not_found`.

  Tests for all the different ways the player could win.
  """
  def check_for_player_win(%Player{letter: letter}, %GameState{board: board}) do
    case board do
      #
      # Check for all the straight across wins
      [%Square{letter: ^letter}, %Square{letter: ^letter}, %Square{letter: ^letter} | _] ->
        {:sq11, :sq12, :sq13}

      [_, _, _, %Square{letter: ^letter}, %Square{letter: ^letter}, %Square{letter: ^letter} | _] ->
        {:sq21, :sq22, :sq23}

      [
        _,
        _,
        _,
        _,
        _,
        _,
        %Square{letter: ^letter},
        %Square{letter: ^letter},
        %Square{letter: ^letter}
      ] ->
        {:sq31, :sq32, :sq33}

      #
      # Check for all the vertical wins
      [
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter},
        _,
        _ | _
      ] ->
        {:sq11, :sq21, :sq31}

      [
        _,
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter},
        _ | _
      ] ->
        {:sq12, :sq22, :sq32}

      [
        _,
        _,
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter},
        _,
        _,
        %Square{letter: ^letter} | _
      ] ->
        {:sq13, :sq23, :sq33}

      #
      # Check for the diagonal wins
      [
        %Square{letter: ^letter},
        _,
        _,
        _,
        %Square{letter: ^letter},
        _,
        _,
        _,
        %Square{letter: ^letter} | _
      ] ->
        {:sq11, :sq22, :sq33}

      [
        _,
        _,
        %Square{letter: ^letter},
        _,
        %Square{letter: ^letter},
        _,
        %Square{letter: ^letter},
        _,
        _ | _
      ] ->
        {:sq13, :sq22, :sq31}

      _ ->
        :not_found
    end
  end

  @doc """
  Return a list of all the squares that are a valid move given the current games
  state.
  """
  @spec valid_moves(t()) :: [atom()]
  def valid_moves(%GameState{board: board}) do
    Enum.reduce(board, [], fn square, acc ->
      if Square.is_open?(square) do
        [square.name | acc]
      else
        acc
      end
    end)
  end

  @doc """
  Check to see if the game is over. Either by a player winning or it ended in a
  draw.
  """
  @spec game_over?(t()) :: boolean()
  def game_over?(%GameState{} = state) do
    a_player_won =
      Enum.any?(state.players, fn player ->
        case check_for_player_win(player, state) do
          :not_found -> false
          {_, _, _} -> true
        end
      end)

    # Return true if a player won or there are no moves left. Otherwise a false
    # is returned.
    a_player_won || valid_moves(state) == []
  end
end
