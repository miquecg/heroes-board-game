defmodule GameBehaviour do
  @moduledoc false

  alias Game.Board
  alias GameError.BadCommand

  @typedoc """
  Unique identifier of each player.

  Base 32 hex encoded string of 26 characters.
  """
  @type player_id :: <<_::208>>

  @typedoc """
  Randomly choose a tile to start.
  """
  @type dice :: (list(tile) -> tile)

  @typep tile :: Board.tile()
  @typep board :: module()

  @doc """
  Join a new player to the game.
  """
  @callback join(board, dice) :: {:ok, player_id} | {:error, :max_heroes}

  @doc """
  Remove player from the game.
  """
  @callback remove(player_id) :: :ok

  @typep command_result :: tile | :released
  @typep command_error :: BadCommand.t() | :dead

  @doc """
  Send command to hero.

  Commands:

  - `t:Game.Board.move/0`
  - `:attack`

  Errors:

  - `:dead`
  - `t:GameError.BadCommand/0`
  """
  @callback play(player_id, command :: any()) :: {:ok, command_result} | {:error, command_error}

  @typep empty_tile :: {}

  @doc """
  Get current position of hero.
  """
  @callback position(player_id) :: tile | empty_tile

  @typep event_callback :: (() -> any())

  @doc """
  Subscribe an event callback to know when hero gets killed.
  """
  @callback subscribe(player_id, event_callback) :: :ok
end

defmodule Game do
  @moduledoc """
  Players entrypoint to the game.
  """
  @behaviour GameBehaviour

  require Game.Board

  alias Game.{Board, Hero, HeroSupervisor}
  alias GameError.BadCommand

  @typep dice :: GameBehaviour.dice()
  @typep tile :: Board.tile()

  @impl true
  def join(board, dice) do
    player_id = generate_id()
    tile = choose_tile(board, dice)

    opts = [
      name: {:via, Registry, {Registry.Heroes, player_id, tile}},
      board: board,
      tile: tile
    ]

    case DynamicSupervisor.start_child(HeroSupervisor, {Hero, opts}) do
      {:ok, _} -> {:ok, player_id}
      {:error, :max_children} -> {:error, :max_heroes}
    end
  end

  @impl true
  def remove(id), do: call_hero(id, :stop)

  @impl true
  def play(id, command) when Board.is_move(command) do
    callback = fn tile ->
      {^tile, _} = Registry.update_value(Registry.Heroes, id, fn _old -> tile end)
      :ok
    end

    call_hero(id, {command, callback})
  end

  @impl true
  def play(id, :attack) do
    callback = fn attacker, from ->
      Registry.dispatch(
        Registry.Game,
        "board",
        &Enum.each(&1, fn
          {^attacker, _} -> :ok
          # :erlang.send/2 is asynchronous and safe
          # https://erlang.org/doc/reference_manual/processes.html#message-sending
          {enemy, _} -> send(enemy, {:fire, from})
        end)
      )
    end

    call_hero(id, {:attack, callback})
  end

  @impl true
  def play(_, _), do: {:error, %BadCommand{}}

  @impl true
  def position(id) do
    case Registry.lookup(Registry.Heroes, id) do
      [{_pid, position}] -> position
      [] -> {}
    end
  end

  @impl true
  def subscribe(id, callback) when is_function(callback) do
    [{pid, _}] = Registry.lookup(Registry.Heroes, id)
    request = {:register, callback, pid}
    :ok = GenServer.call(Game.BoardSubscriber, request)
  end

  @spec generate_id :: binary()
  defp generate_id do
    random_bytes = :crypto.strong_rand_bytes(16)
    Base.hex_encode32(random_bytes, padding: false)
  end

  @spec choose_tile(module(), dice) :: tile
  defp choose_tile(board, dice) do
    tiles = board.tiles()
    dice.(tiles)
  end

  defp call_hero(id, request) when is_binary(id) do
    call_hero({:via, Registry, {Registry.Heroes, id}}, request)
  end

  defp call_hero(hero, :stop) do
    {:ok, _pid} = Task.start(GenServer, :stop, [hero])
    :ok
  end

  defp call_hero(hero, request) do
    case GenServer.call(hero, request) do
      :dead -> {:error, :dead}
      reply -> {:ok, reply}
    end
  end
end
