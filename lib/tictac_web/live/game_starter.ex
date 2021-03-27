defmodule TictacWeb.GameStarter do
  @moduledoc """
  Struct and changeset for starting a game.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Tictac.GameState
  alias Tictac.GameServer

  embedded_schema do
    field :name, :string
    field :game_code, :string
    field :type, Ecto.Enum, values: [:start, :join], default: :start
  end

  @type t :: %GameStarter{
          name: nil | String.t(),
          game_code: nil | String.t(),
          type: :start | :join
        }

  @doc false
  def insert_changeset(attrs) do
    %GameStarter{}
    |> cast(attrs, [:name, :game_code])
    |> validate_required([:name])
    |> validate_length(:name, max: 15)
    |> validate_length(:game_code, is: 4)
    |> uppercase_game_code()
    |> validate_game_code()
    |> compute_type()
  end

  @doc false
  def uppercase_game_code(changeset) do
    case get_field(changeset, :game_code) do
      nil -> changeset
      value -> put_change(changeset, :game_code, String.upcase(value))
    end
  end

  @doc false
  def validate_game_code(changeset) do
    # Don't check for a running game server if there are errors on the game_code
    # field
    if changeset.errors[:game_code] do
      changeset
    else
      case get_field(changeset, :game_code) do
        nil ->
          changeset

        value ->
          if GameServer.server_found?(value) do
            changeset
          else
            add_error(changeset, :game_code, "not a running game")
          end
      end
    end
  end

  @doc false
  # Compute the "type" field based on the game_code value
  def compute_type(changeset) do
    case get_field(changeset, :game_code) do
      nil ->
        put_change(changeset, :type, :start)

      _game_code ->
        put_change(changeset, :type, :join)
    end
  end

  @doc """
  Get the game code to use for starting or joining the game.
  """
  @spec get_game_code(t()) :: {:ok, GameState.game_code()} | {:error, String.t()}
  def get_game_code(%GameStarter{type: :join, game_code: code}), do: {:ok, code}

  def get_game_code(%GameStarter{type: :start}) do
    GameServer.generate_game_code()
  end

  @doc """
  Create the GameStart struct data from the changeset if valid.
  """
  @spec create(params :: map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    params
    |> insert_changeset()
    |> apply_action(:insert)
  end
end
