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
  Join a new player to the game.
  """
  @callback join(board :: module(), dice :: fun()) :: player_id

  @doc """
  Remove player from the game.
  """
  @callback remove(player_id) :: :ok

  @doc """
  Send command to hero.

  Commands:

  - `t:Game.Board.move/0`
  - `:attack`

  Errors:

  - `:dead`
  - `GameError.BadCommand`
  """
  @callback play(player_id, cmd :: any()) :: {:ok, result} | {:error, error}
            when result: Board.tile() | :released,
                 error: :dead | %BadCommand{}

  @doc """
  Get current position of hero.
  """
  @callback position(player_id) :: Board.tile() | {}

  @doc """
  Subscribe to a hero event in the game via callback.
  """
  @callback subscribe(player_id, event :: :killed, callback :: (() -> any())) :: :ok
end

defmodule Game do
  @moduledoc """
  Players entrypoint to the game.
  """
  @behaviour GameBehaviour

  require Game.Board

  alias Game.{Board, Hero, HeroSupervisor}
  alias GameError.BadCommand

  @type update :: (Board.tile() -> :ok)
  @type attack :: (pid(), Board.tile() -> :ok)

  @impl true
  def join(board, dice) do
    player_id = generate_id()
    tile = choose_tile(board, dice)

    opts = [
      name: {:via, Registry, {Registry.Heroes, player_id, tile}},
      board: board,
      tile: tile
    ]

    {:ok, _pid} = DynamicSupervisor.start_child(HeroSupervisor, {Hero, opts})

    player_id
  end

  @impl true
  def remove(id), do: call_hero(id, :stop)

  @impl true
  def play(id, cmd) when Board.is_move(cmd), do: call_hero(id, {cmd, update_callback(id)})

  @impl true
  def play(id, :attack), do: call_hero(id, {:attack, attack_callback()})

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
  def subscribe(id, :killed, callback) when is_function(callback) do
    [{pid, _}] = Registry.lookup(Registry.Heroes, id)
    request = {:register, callback, pid}
    :ok = GenServer.call(Game.BoardSubscriber, request)
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

  @spec update_callback(binary()) :: update
  defp update_callback(id) do
    fn tile ->
      {^tile, _} = Registry.update_value(Registry.Heroes, id, fn _old -> tile end)
      :ok
    end
  end

  @spec attack_callback :: attack
  defp attack_callback do
    fn attacker, from ->
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
