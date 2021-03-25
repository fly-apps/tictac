defmodule TictacWeb.PlayLive do
  use TictacWeb, :live_view
  alias Phoenix.PubSub
  alias Tictac.GameState
  alias Tictac.GameServer

  @impl true
  def mount(%{"game" => game_code, "player" => player_id} = _params, _session, socket) do
    game_state =
      if connected?(socket) do
        # Subscribe to game update notifications
        PubSub.subscribe(Tictac.PubSub, "game:#{game_code}")
        GameServer.get_current_game_state(game_code)
      else
        %GameState{}
      end

    player = GameState.get_player(game_state, player_id)

    {:ok, assign(socket, game_code: game_code, player: player, game: game_state)}
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
  def handle_info({:game_state, %GameState{} = state} = _event, socket) do
    updated_socket =
      socket
      |> clear_flash()
      |> assign(:game, state)

    {:noreply, updated_socket}
  end
end
