defmodule TictacWeb.PageLive do
  use TictacWeb, :live_view
  import Phoenix.HTML.Form
  alias Tictac.Player
  alias Tictac.GameServer

  @impl true
  def mount(_params, _session, socket) do
    changeset = Player.insert_changeset(%{})

    {:ok,
     socket
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"player" => params}, socket) do
    changeset = Player.insert_changeset(params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"player" => params}, socket) do
    # TODO: You can generate unique game codes to allow for multiple simultaneous games
    game_code = "ABCD"

    params
    |> Player.insert_changeset()
    |> Player.create()
    |> case do
      {:ok, %Player{} = player} ->
        case GameServer.start_or_join(game_code, player) do
          {:ok, _} ->
            socket =
              push_redirect(socket,
                to: Routes.play_path(socket, :index, game: game_code, player: player.id)
              )

            {:noreply, socket}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
