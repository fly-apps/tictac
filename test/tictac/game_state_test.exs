defmodule Tictac.GameStateTest do
  use ExUnit.Case
  import Tictac.Fixtures

  doctest Tictac.GameState

  alias Tictac.GameState
  alias Tictac.Player
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

      assert {:sq11, :sq12, :sq13} == GameState.check_for_player_win(state, p)

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

      assert {:sq21, :sq22, :sq23} == GameState.check_for_player_win(state, p)

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

      assert {:sq31, :sq32, :sq33} == GameState.check_for_player_win(state, p)
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

      assert {:sq11, :sq21, :sq31} == GameState.check_for_player_win(state, p)

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

      assert {:sq12, :sq22, :sq32} == GameState.check_for_player_win(state, p)

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

      assert {:sq13, :sq23, :sq33} == GameState.check_for_player_win(state, p)
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

      assert {:sq11, :sq22, :sq33} == GameState.check_for_player_win(state, p)

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

      assert {:sq13, :sq22, :sq31} == GameState.check_for_player_win(state, p)
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

      assert :not_found == GameState.check_for_player_win(state, p)
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

      assert :not_found == GameState.check_for_player_win(state, player)
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

  describe "result/1" do
    test "return :playing while game still going", %{players: players} do
      assert GameState.result(%GameState{players: players}) == :playing

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

      assert GameState.result(state) == :playing
    end

    test "return winning player when a player has won", %{players: players} do
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

      assert GameState.result(state) == hd(players)
    end

    test "return :draw when the game is a draw", %{players: players} do
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

      assert GameState.result(state) == :draw
    end
  end

  describe "join_game/2" do
    test "second player can join", %{players: [p1, p2]} do
      state = GameState.new(p1)
      assert {:ok, new_state} = GameState.join_game(state, p2)
      assert length(new_state.players) == 2
    end

    test "deny more than 2 players", %{players: [p1, p2]} do
      state = GameState.new(p1)
      assert {:ok, new_state} = GameState.join_game(state, p2)

      assert {:error, "Only 2 players allowed"} =
               GameState.join_game(new_state, %Player{name: "Fran", letter: "X"})
    end

    test "make 2nd player be opposing letter", %{players: [p1, p2]} do
      assert p1.letter == "O"
      assert p2.letter == "X"
      # Try to add second player also as letter "O"
      p2 = %Player{p2 | letter: "O"}
      state = GameState.new(p1)
      assert {:ok, new_state} = GameState.join_game(state, p2)
      [_p1, added_p2] = new_state.players
      assert added_p2.letter == "X"
    end

    test "errors joining a game that wasn't started by a player", %{players: [p1, _]} do
      state = %GameState{}
      assert {:error, "Can only join a created game"} == GameState.join_game(state, p1)
    end
  end

  describe "start/1" do
    test "when 2 players and not already started, set status to playing", %{players: players} do
      [p1 | _] = players
      state = %GameState{status: :not_started, players: players}
      assert {:ok, new_state} = GameState.start(state)
      assert new_state.status == :playing
      assert new_state.player_turn == p1.letter
    end

    test "a new game starts with O player", %{players: [p1, p2]} do
      # Verify that player1 is O
      assert p1.letter == "O"
      assert p2.letter == "X"
      # Start with player2 who is currently "X"
      {:ok, state} =
        p2
        |> GameState.new()
        |> GameState.join_game(p1)

      {:ok, game} = GameState.start(state)
      assert game.status == :playing
      assert game.player_turn != nil

      refute GameState.player_turn?(game, p2)
      assert GameState.player_turn?(game, p1)
    end

    test "reject when already playing", %{players: players} do
      state = %GameState{status: :playing, players: players}
      assert {:error, "Game in play"} == GameState.start(state)
    end

    test "reject when don't missing players", %{players: [p1, _]} do
      state = %GameState{status: :not_started, players: []}
      assert {:error, "Missing players"} == GameState.start(state)

      state = %GameState{status: :not_started, players: [p1]}
      assert {:error, "Missing players"} == GameState.start(state)
    end

    test "can't start when done", %{players: players} do
      state = %GameState{status: :done, players: players}
      assert {:error, "Game is done"} == GameState.start(state)
    end
  end

  describe "player_turn?/2" do
    test "correctly identifies when it's the player's turn", %{players: [p1, p2]} do
      state = %GameState{players: [p1, p2], player_turn: "O"}
      assert GameState.player_turn?(state, p1)
      refute GameState.player_turn?(state, p2)

      state = %GameState{players: [p1, p2], player_turn: "X"}
      refute GameState.player_turn?(state, p1)
      assert GameState.player_turn?(state, p2)
    end
  end

  describe "find_square/2" do
    test "return ok tuple with square when found", %{players: [p1, _p2]} do
      state = GameState.new(p1)
      assert {:ok, %Square{name: :sq11}} = GameState.find_square(state, :sq11)
      assert {:ok, %Square{name: :sq22}} = GameState.find_square(state, :sq22)
      assert {:ok, %Square{name: :sq33}} = GameState.find_square(state, :sq33)
    end

    test "return error tuple when not found", %{players: [p1, _p2]} do
      state = GameState.new(p1)
      assert {:error, "Square not found"} == GameState.find_square(state, :invalid)
      assert {:error, "Square not found"} == GameState.find_square(state, :sq00)
    end
  end

  describe "place_letter/3" do
    test "claim a square with a letter" do
      updated_state =
        %GameState{}
        |> GameState.place_letter("X", :sq11)
        |> GameState.place_letter("X", :sq21)
        |> GameState.place_letter("X", :sq31)

      assert {:ok, %Square{letter: "X"}} = GameState.find_square(updated_state, :sq11)
      assert {:ok, %Square{letter: "X"}} = GameState.find_square(updated_state, :sq21)
      assert {:ok, %Square{letter: "X"}} = GameState.find_square(updated_state, :sq31)
      assert {:ok, %Square{letter: nil}} = GameState.find_square(updated_state, :sq23)
    end
  end

  describe "move/3" do
    setup %{players: [p1, p2]} do
      {:ok, game} =
        p1
        |> GameState.new()
        |> GameState.join_game(p2)

      {:ok, game} = GameState.start(game)
      %{game: game}
    end

    test "return error when square already taken", %{game: game, players: [p1, p2]} do
      {:ok, updated} = GameState.move(game, p1, :sq11)
      assert {:error, "Square already taken"} = GameState.move(updated, p2, :sq11)
    end

    test "return error when square not found", %{game: game, players: [p1, _p2]} do
      assert {:error, "Square not found"} = GameState.move(game, p1, :sq00)
    end

    test "returns new state with other player's turn", %{game: game, players: [p1, p2]} do
      game
      |> GameState.move(p1, :sq11)
      |> assert_player_turn(p2)
    end

    test "updates board with the move", %{game: game, players: [p1, _p2]} do
      game
      |> GameState.move(p1, :sq11)
      |> assert_square_letter(:sq11, p1.letter)
    end

    test "returns error when wrong player goes", %{game: game, players: [p1, p2]} do
      assert_player_turn(game, p1)
      assert {:error, "Not your turn!"} == GameState.move(game, p2, :sq11)
    end

    test "returns error when occupied place given", %{game: game, players: [p1, p2]} do
      {:ok, move_1} = GameState.move(game, p1, :sq11)
      assert {:error, "Square already taken"} == GameState.move(move_1, p2, :sq11)
    end
  end

  describe "full game run through" do
    test "a full winning game works", %{players: [p1, p2]} do
      {:ok, game} =
        p1
        |> GameState.new()
        |> GameState.join_game(p2)

      {:ok, game} = GameState.start(game)

      game
      |> assert_player_turn(p1)
      |> GameState.move(p1, :sq11)
      |> assert_player_turn(p2)
      |> assert_square_letter(:sq11, "O")
      # O| |
      # -+-+-
      #  | |
      # -+-+-
      #  | |
      |> GameState.move(p2, :sq22)
      |> assert_player_turn(p1)
      |> assert_square_letter(:sq22, "X")
      # O| |
      # -+-+-
      #  |X|
      # -+-+-
      #  | |
      |> GameState.move(p1, :sq33)
      |> assert_player_turn(p2)
      # O| |
      # -+-+-
      #  |X|
      # -+-+-
      #  | |O
      |> GameState.move(p2, :sq31)
      |> assert_player_turn(p1)
      # O| |
      # -+-+-
      #  |X|
      # -+-+-
      # X| |O
      |> GameState.move(p1, :sq13)
      # O| |O
      # -+-+-
      #  |X|
      # -+-+-
      # X| |O
      |> GameState.move(p2, :sq12)
      |> assert_status(:playing)
      # O|X|O
      # -+-+-
      #  |X|
      # -+-+-
      # X| |O
      |> assert_result(:playing)
      |> GameState.move(p1, :sq23)
      # O|X|O
      # -+-+-
      #  |X|O
      # -+-+-
      # X| |O
      |> assert_status(:done)
      |> assert_result(p1)
    end

    test "a full draw game works", %{players: [p1, p2]} do
      {:ok, game} =
        p1
        |> GameState.new()
        |> GameState.join_game(p2)

      {:ok, game} = GameState.start(game)

      game
      |> assert_player_turn(p1)
      |> GameState.move(p1, :sq11)
      |> assert_player_turn(p2)
      |> assert_result(:playing)
      # O| |
      # -+-+-
      #  | |
      # -+-+-
      #  | |
      |> GameState.move(p2, :sq22)
      |> assert_player_turn(p1)
      # O| |
      # -+-+-
      #  |X|
      # -+-+-
      #  | |
      |> GameState.move(p1, :sq21)
      |> assert_player_turn(p2)
      # O| |
      # -+-+-
      # O|X|
      # -+-+-
      #  | |
      |> GameState.move(p2, :sq31)
      |> assert_player_turn(p1)
      # O| |
      # -+-+-
      # O|X|
      # -+-+-
      # X| |
      |> GameState.move(p1, :sq13)
      # O| |O
      # -+-+-
      # O|X|
      # -+-+-
      # X| |
      |> GameState.move(p2, :sq12)
      |> assert_status(:playing)
      # O|X|O
      # -+-+-
      # O|X|
      # -+-+-
      # X| |
      |> GameState.move(p1, :sq32)
      # O|X|O
      # -+-+-
      # O|X|
      # -+-+-
      # X|O|
      |> GameState.move(p2, :sq23)
      # O|X|O
      # -+-+-
      # O|X|X
      # -+-+-
      # X|O|
      |> GameState.move(p1, :sq33)
      # O|X|O
      # -+-+-
      # O|X|X
      # -+-+-
      # X|O|O
      |> assert_status(:done)
      |> assert_result(:draw)
    end
  end

  defp assert_status({:ok, %GameState{status: status} = state}, expected) do
    assert status == expected
    {:ok, state}
  end

  defp assert_player_turn(%GameState{} = state, %Player{} = player) do
    assert GameState.player_turn?(state, player)
    state
  end

  defp assert_player_turn({:ok, %GameState{} = state}, %Player{} = player) do
    assert_player_turn(state, player)
    {:ok, state}
  end

  defp assert_result({:ok, %GameState{} = state}, result_value) do
    assert result_value == GameState.result(state)
    {:ok, state}
  end

  defp assert_square_letter({:ok, %GameState{} = state}, square, letter) do
    assert {:ok, %Square{letter: ^letter}} = GameState.find_square(state, square)
    {:ok, state}
  end
end
