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
  @typep empty_tile :: {}
  @typep board :: module()

  @typep ok(result) :: {:ok, result}
  @typep error(reason) :: {:error, reason}

  @doc """
  Join a new player to the game.
  """
  @callback join(board, dice) :: ok(player_id) | error(:max_heroes)

  @doc """
  Remove player from the game.
  """
  @callback remove(player_id) :: :ok

  @doc """
  Send command to hero.

  Commands:

  - `t:Game.Board.move/0`
  - `:attack`

  Error reasons:

  - `:not_found`
  - `t:GameError.BadCommand/0`
  """
  @callback play(player_id, command :: any()) ::
              ok(tile | :released)
              | error(:not_found | BadCommand.t())

  @doc """
  Get current position of hero.
  """
  @callback position(player_id) :: tile | empty_tile

  @doc """
  Subscribe a `t:pid/0` to receive a `:game_over` message
  when player's hero gets killed.
  """
  @callback subscribe(player_id, pid()) :: :ok | error(:not_found)
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
  @typep player_id :: GameBehaviour.player_id()

  @typep tile :: Board.tile()

  @typep maybe_pid :: pid() | nil

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
  def remove(id) do
    maybe_pid =
      id
      |> get_hero()
      |> List.first()

    terminate_hero(maybe_pid)
  end

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
    case get_position(id) do
      [position] -> position
      [] -> {}
    end
  end

  @impl true
  def subscribe(id, subscriber) when is_pid(subscriber) do
    case get_hero(id) do
      [hero] ->
        callback = fn -> send(subscriber, :game_over) end
        request = {:register, callback, hero}
        :ok = GenServer.call(Game.BoardSubscriber, request)

      [] ->
        {:error, :not_found}
    end
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

  @spec get_hero(player_id) :: [pid()]
  defp get_hero(id), do: select(id, :"$2")

  @spec get_position(player_id) :: [tile]
  defp get_position(id), do: select(id, :"$3")

  defp select(key, entry) do
    Registry.select(Registry.Heroes, [{{key, :"$2", :"$3"}, [], [entry]}])
  end

  defp call_hero(id, request) when is_binary(id) do
    call_hero({:via, Registry, {Registry.Heroes, id}}, request)
  end

  defp call_hero(hero, request) do
    reply = GenServer.call(hero, request)
    {:ok, reply}
  catch
    :exit, _ -> {:error, :not_found}
  end

  @spec terminate_hero(maybe_pid) :: :ok
  defp terminate_hero(child) when is_pid(child) do
    _ = DynamicSupervisor.terminate_child(HeroSupervisor, child)
    :ok
  end

  defp terminate_hero(nil), do: :ok
end
