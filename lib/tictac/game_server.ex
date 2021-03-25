defmodule Tictac.GameServer do
  @moduledoc """
  A GenServer that manages and models the state for a specific game instance.
  """
  use GenServer
  require Logger

  alias __MODULE__
  alias Tictac.Player
  alias Tictac.GameState
  alias Phoenix.PubSub

  # Client

  def child_spec(opts) do
    name = Keyword.get(opts, :name, GameServer)
    player = Keyword.fetch!(opts, :player)

    %{
      id: "#{GameServer}_#{name}",
      start: {GameServer, :start_link, [name, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  @doc """
  Start a GameServer with the specified game_code as the name.
  """
  def start_link(name, %Player{} = player) do
    case GenServer.start_link(GameServer, %{player: player, code: name}, name: via_tuple(name)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Already started GameServer #{inspect(name)} at #{inspect(pid)}, returning :ignore"
        )

        :ignore
    end
  end

  @doc """
  Start a new game or join an existing game.
  """
  @spec start_or_join(GameState.game_code(), Player.t()) ::
          {:ok, :started | :joined} | {:error, String.t()}
  def start_or_join(game_code, %Player{} = player) do
    case Horde.DynamicSupervisor.start_child(
           Tictac.DistributedSupervisor,
           {GameServer, [name: game_code, player: player]}
         ) do
      {:ok, _pid} ->
        Logger.info("Started game server #{inspect(game_code)}")
        {:ok, :started}

      :ignore ->
        Logger.info("Game server #{inspect(game_code)} already running. Joining")

        case join_game(game_code, player) do
          :ok -> {:ok, :joined}
          {:error, _reason} = error -> error
        end
    end
  end

  @doc """
  Join a running game server
  """
  @spec join_game(GameState.game_code(), Player.t()) :: :ok | {:error, String.t()}
  def join_game(game_code, %Player{} = player) do
    GenServer.call(via_tuple(game_code), {:join_game, player})
  end

  @doc """
  Perform a move for the player
  """
  @spec move(GameState.game_code(), player_id :: String.t(), square :: atom()) ::
          :ok | {:error, String.t()}
  def move(game_code, player_id, square) do
    GenServer.call(via_tuple(game_code), {:move, player_id, square})
  end

  @doc """
  Request and return the current game state.
  """
  @spec get_current_game_state(GameState.game_code()) ::
          GameState.t() | {:error, String.t()}
  def get_current_game_state(game_code) do
    GenServer.call(via_tuple(game_code), :current_state)
  end

  @doc """
  Reset the current game keeping the same players.
  """
  @spec restart(GameState.game_code()) :: :ok | {:error, String.t()}
  def restart(game_code) do
    GenServer.call(via_tuple(game_code), :restart)
  end

  # Server (callbacks)

  @impl true
  def init(%{player: player, code: code}) do
    # Create the new game state with the creating player assigned
    {:ok, GameState.new(code, player)}
  end

  @impl true
  def handle_call({:join_game, %Player{} = player}, _from, %GameState{} = state) do
    with {:ok, new_state} <- GameState.join_game(state, player),
         {:ok, started} <- GameState.start(new_state) do
      broadcast_game_state(started)
      {:reply, :ok, started}
    else
      {:error, reason} = error ->
        Logger.error("Failed to join and start game. Error: #{inspect(reason)}")
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:current_state, _from, %GameState{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:move, player_id, square}, _from, %GameState{} = state) do
    with {:ok, player} <- GameState.find_player(state, player_id),
         {:ok, new_state} <- GameState.move(state, player, square) do
      broadcast_game_state(new_state)
      {:reply, :ok, new_state}
    else
      {:error, reason} = error ->
        Logger.error("Player move failed. Error: #{inspect(reason)}")
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:restart, _from, %GameState{} = state) do
    new_state = GameState.restart(state)
    broadcast_game_state(new_state)
    {:reply, :ok, new_state}
  end

  def broadcast_game_state(%GameState{} = state) do
    PubSub.broadcast(Tictac.PubSub, "game:#{state.code}", {:game_state, state})
  end

  @doc """
  Return the `:via` tuple for referencing and interacting with a specific
  GameServer.
  """
  def via_tuple(game_code), do: {:via, Horde.Registry, {Tictac.GameRegistry, game_code}}

  @doc """
  Lookup the GameServer and report if it is found. Returns a boolean.
  """
  @spec server_found?(GameState.game_code()) :: boolean()
  def server_found?(game_code) do
    # Look up the game in the registry. Return if a match is found.
    case Horde.Registry.lookup(Tictac.GameRegistry, game_code) do
      [] -> false
      [{pid, _} | _] when is_pid(pid) -> true
    end
  end
end
