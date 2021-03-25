defmodule TictacWeb.PlayLive do
  use TictacWeb, :live_view
  require Logger
  alias Phoenix.PubSub
  alias Tictac.GameState
  alias Tictac.GameServer

  @impl true
  def mount(%{"game" => game_code, "player" => player_id} = _params, _session, socket) do
    if connected?(socket) do
      # Subscribe to game update notifications
      PubSub.subscribe(Tictac.PubSub, "game:#{game_code}")
      send(self(), :load_game_state)
    end

    {:ok,
     assign(socket,
       game_code: game_code,
       player_id: player_id,
       player: nil,
       game: %GameState{},
       server_found: GameServer.server_found?(game_code)
     )}
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: Routes.page_path(socket, :index))}
  end

  @impl true
  def handle_event(
        "move",
        %{"square" => square},
        %{assigns: %{game_code: code, player: player}} = socket
      ) do
    case GameServer.move(code, player.id, String.to_existing_atom(square)) do
      :ok ->
        # We get the new official game state through a PubSub event
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_event("restart", _params, %{assigns: %{game_code: code}} = socket) do
    case GameServer.restart(code) do
      :ok ->
        # We get the new official game state through a PubSub event
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_info(:load_game_state, %{assigns: %{server_found: true}} = socket) do
    case GameServer.get_current_game_state(socket.assigns.game_code) do
      %GameState{} = game ->
        player = GameState.get_player(game, socket.assigns.player_id)
        {:noreply, assign(socket, server_found: true, game: game, player: player)}

      error ->
        Logger.error("Failed to load game server state. #{inspect(error)}")
        {:noreply, assign(socket, :server_found, false)}
    end
  end

  def handle_info(:load_game_state, socket) do
    Logger.info("Game server #{inspect(socket.assigns.game_code)} not found")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:game_state, %GameState{} = state} = _event, socket) do
    updated_socket =
      socket
      |> clear_flash()
      |> assign(:game, state)

    {:noreply, updated_socket}
  end
end
