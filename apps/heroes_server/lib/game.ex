defmodule GameBehaviour do
  @moduledoc false

  alias Game.Board
  alias GameError.BadCommand

  @typedoc """
  Unique identifier for every active player.

  Base 32 hex encoded string of 26 characters.
  """
  @type player_id :: <<_::208>>

  @doc """
  Join a new player to the game creating a hero.
  """
  @callback join(board :: module(), dice :: fun()) :: player_id

  @doc """
  Remove player's hero from the game.
  """
  @callback remove(player_id) :: :ok

  @doc """
  Send command to player's hero.

  Valid commands:

  - `t:Game.Board.move/0`
  - `:attack`

  Error values:

  - `:noop`: hero is dead and cannot execute any further actions
  - `%GameError.BadCommand{}`
  """
  @callback play(player_id, cmd :: term()) :: {:ok, result} | {:error, error}
            when result: Board.tile() | :released,
                 error: :noop | %BadCommand{}

  @doc """
  Get current hero position.
  """
  @callback position(player_id) :: Board.tile()
end

defmodule Game do
  @moduledoc """
  Players entrypoint to the game.
  """
  @behaviour GameBehaviour

  alias Game.{Board, HeroServer, HeroSupervisor}

  @impl true
  def join(board, dice) do
    player_id = generate_id()
    tile = choose_tile(board, dice)

    opts = [
      name: {:via, Registry, {Game.Registry, player_id, tile}},
      board: board,
      tile: tile
    ]

    {:ok, _pid} = DynamicSupervisor.start_child(HeroSupervisor, {HeroServer, opts})

    player_id
  end

  @impl true
  def remove(id) do
    server = {:via, Registry, {Game.Registry, id}}
    {:ok, _pid} = Task.start(GenServer, :stop, [server])
    :ok
  end

  @impl true
  def position(id) do
    [{_pid, position}] = Registry.lookup(Game.Registry, id)
    position
  end

  @spec generate_id :: binary()
  defp generate_id do
    random_bytes = :crypto.strong_rand_bytes(16)
    Base.hex_encode32(random_bytes, padding: false)
  end

  @spec choose_tile(module(), fun()) :: Board.tile()
  defp choose_tile(board, dice) do
    tiles = board.tiles()
    dice.(tiles)
  end
end
