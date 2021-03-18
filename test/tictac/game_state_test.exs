defmodule Tictac.GameStateTest do
  use ExUnit.Case
  import Tictac.Fixtures

  doctest Tictac.GameState

  alias Tictac.GameState
  alias Tictac.Square

  setup do
    player = fixture(:player, %{letter: "O"})
    opponent = fixture(:player, %{letter: "X"})
    %{players: [player, opponent], player: player}
  end

  describe "check_for_player_win/2" do
    test "correctly identify horizontal player wins", %{players: players, player: p} do
      # O|O|O
      # -+-+-
      #  |X|
      # -+-+-
      #  |X|
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, "O"),
          Square.build(:sq13, "O"),
          Square.build(:sq21),
          Square.build(:sq22, "X"),
          Square.build(:sq23),
          Square.build(:sq31),
          Square.build(:sq32, "X"),
          Square.build(:sq33)
        ]
      }

      assert {:sq11, :sq12, :sq13} == GameState.check_for_player_win(p, state)

      #  |X|
      # -+-+-
      # O|O|O
      # -+-+-
      #  |X|
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11),
          Square.build(:sq12, "X"),
          Square.build(:sq13),
          Square.build(:sq21, "O"),
          Square.build(:sq22, "O"),
          Square.build(:sq23, "O"),
          Square.build(:sq31),
          Square.build(:sq32, "X"),
          Square.build(:sq33)
        ]
      }

      assert {:sq21, :sq22, :sq23} == GameState.check_for_player_win(p, state)

      #  |X|
      # -+-+-
      #  |X|
      # -+-+-
      # O|O|O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11),
          Square.build(:sq12, "X"),
          Square.build(:sq13),
          Square.build(:sq21),
          Square.build(:sq22, "X"),
          Square.build(:sq23),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "O"),
          Square.build(:sq33, "O")
        ]
      }

      assert {:sq31, :sq32, :sq33} == GameState.check_for_player_win(p, state)
    end

    test "correctly identify vertical player wins", %{players: players, player: p} do
      # O| |
      # -+-+-
      # O|X|
      # -+-+-
      # O| |X
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, nil),
          Square.build(:sq13, nil),
          Square.build(:sq21, "O"),
          Square.build(:sq22, "X"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "O"),
          Square.build(:sq32, nil),
          Square.build(:sq33, "X")
        ]
      }

      assert {:sq11, :sq21, :sq31} == GameState.check_for_player_win(p, state)

      #  |O|
      # -+-+-
      #  |O|
      # -+-+-
      # X|O|X
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, nil),
          Square.build(:sq12, "O"),
          Square.build(:sq13, nil),
          Square.build(:sq21, nil),
          Square.build(:sq22, "O"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "X"),
          Square.build(:sq32, "O"),
          Square.build(:sq33, "X")
        ]
      }

      assert {:sq12, :sq22, :sq32} == GameState.check_for_player_win(p, state)

      # X| |O
      # -+-+-
      #  |X|O
      # -+-+-
      #  | |O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "X"),
          Square.build(:sq12, nil),
          Square.build(:sq13, "O"),
          Square.build(:sq21, nil),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, nil),
          Square.build(:sq32, nil),
          Square.build(:sq33, "O")
        ]
      }

      assert {:sq13, :sq23, :sq33} == GameState.check_for_player_win(p, state)
    end

    test "correctly identify diagonal player wins", %{players: players, player: p} do
      # O| |
      # -+-+-
      # X|O|
      # -+-+-
      # X| |O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, nil),
          Square.build(:sq13, nil),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "O"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "X"),
          Square.build(:sq32, nil),
          Square.build(:sq33, "O")
        ]
      }

      assert {:sq11, :sq22, :sq33} == GameState.check_for_player_win(p, state)

      # X| |O
      # -+-+-
      #  |O|
      # -+-+-
      # O| |X
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "X"),
          Square.build(:sq12, nil),
          Square.build(:sq13, "O"),
          Square.build(:sq21, nil),
          Square.build(:sq22, "O"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "O"),
          Square.build(:sq32, nil),
          Square.build(:sq33, "X")
        ]
      }

      assert {:sq13, :sq22, :sq31} == GameState.check_for_player_win(p, state)
    end

    test "return :not_found when player has not won", %{players: players, player: p} do
      #  | |
      # -+-+-
      # X|O|
      # -+-+-
      # X| |O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, nil),
          Square.build(:sq12, nil),
          Square.build(:sq13, nil),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "O"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "X"),
          Square.build(:sq32, nil),
          Square.build(:sq33, "O")
        ]
      }

      assert :not_found == GameState.check_for_player_win(p, state)
    end

    test "return :not_found when other player won" do
      # O| |
      # -+-+-
      # X|O|
      # -+-+-
      # X| |O

      # Changed the letter for the player
      player = fixture(:player, %{letter: "X"})
      opponent = fixture(:player, %{letter: "O"})

      state = %GameState{
        players: [player, opponent],
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, nil),
          Square.build(:sq13, nil),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "O"),
          Square.build(:sq23, nil),
          Square.build(:sq31, "X"),
          Square.build(:sq32, nil),
          Square.build(:sq33, "O")
        ]
      }

      assert :not_found == GameState.check_for_player_win(player, state)
    end
  end

  describe "valid_moves/1" do
    test "returns empty list when no moves left", %{players: players} do
      # O|O|X
      # -+-+-
      # X|X|O
      # -+-+-
      # O|X|O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, "O"),
          Square.build(:sq13, "X"),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "X"),
          Square.build(:sq33, "O")
        ]
      }

      assert [] == GameState.valid_moves(state)
    end

    test "returns all the valid moves given the current game state", %{players: players} do
      # O|O|X
      # -+-+-
      # X|X|O
      # -+-+-
      # O|X|
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, "O"),
          Square.build(:sq13, "X"),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "X"),
          Square.build(:sq33)
        ]
      }

      assert [:sq33] == GameState.valid_moves(state)

      # O| |X
      # -+-+-
      #  |X|O
      # -+-+-
      # O|X|
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, nil),
          Square.build(:sq13, "X"),
          Square.build(:sq21, nil),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "X"),
          Square.build(:sq33, nil)
        ]
      }

      result = GameState.valid_moves(state)
      assert [:sq12, :sq21, :sq33] == Enum.sort(result)
    end
  end

  describe "game_over?/1" do
    test "return false while game still going", %{players: players} do
      refute GameState.game_over?(%GameState{players: players})

      # O|O|X
      # -+-+-
      # X|X|O
      # -+-+-
      # O|X|
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, "O"),
          Square.build(:sq13, "X"),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "X"),
          Square.build(:sq33)
        ]
      }

      refute GameState.game_over?(state)
    end

    test "return true when a player has won", %{players: players} do
      # X| |O
      # -+-+-
      #  |X|O
      # -+-+-
      #  | |O
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "X"),
          Square.build(:sq12, nil),
          Square.build(:sq13, "O"),
          Square.build(:sq21, nil),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, nil),
          Square.build(:sq32, nil),
          Square.build(:sq33, "O")
        ]
      }

      assert GameState.game_over?(state)
    end

    test "return true when the game is a draw", %{players: players} do
      # O|O|X
      # -+-+-
      # X|X|O
      # -+-+-
      # O|X|X
      state = %GameState{
        players: players,
        board: [
          Square.build(:sq11, "O"),
          Square.build(:sq12, "O"),
          Square.build(:sq13, "X"),
          Square.build(:sq21, "X"),
          Square.build(:sq22, "X"),
          Square.build(:sq23, "O"),
          Square.build(:sq31, "O"),
          Square.build(:sq32, "X"),
          Square.build(:sq33, "X")
        ]
      }

      assert GameState.game_over?(state)
    end
  end
end
