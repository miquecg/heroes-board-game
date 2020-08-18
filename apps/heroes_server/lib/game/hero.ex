defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer

  require Logger

  alias Game.Board
  alias GameError.BadCommand

  @moves [:up, :down, :left, :right]
  @actions [:play, :broadcast]

  @alive_status :alive
  @dead_status :dead

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.tile(),
           alive: boolean()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :tile]

    defstruct [alive: true] ++ @enforce_keys
  end

  ## Client

  @doc """
  Spawn a hero.

  Requires options `:board` and `:tile`.

  Can be registered under a `:name`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    case Keyword.pop(opts, :name) do
      {nil, opts} -> GenServer.start_link(__MODULE__, opts)
      {name, opts} -> GenServer.start_link(__MODULE__, opts, name: name)
    end
  end

  @doc """
  Send a command to control a hero.

  `server` is the hero reference and `cmd`
  can be `t:Game.Board.moves/0` or atom `:attack`.

  Returns `{:ok, tile}`, `{:ok, :launched}` or
  `{:error, :noop}` when hero is dead and
  cannot execute any further actions.

  For invalid commands returns exception
  `GameError.BadCommand` in the error tuple.
  """
  @spec control(GenServer.server(), term()) :: {:ok, tile | :launched} | {:error, error}
        when tile: Board.tile(), error: :noop | %BadCommand{}
  def control(server, cmd)

  def control(server, cmd) when cmd in @moves, do: GenServer.call(server, {:play, cmd})

  def control(server, :attack) do
    children = Supervisor.which_children(Game.HeroSupervisor)

    enemies =
      Enum.flat_map(children, fn
        {_, ^server, :worker, [__MODULE__]} -> []
        {_, hero, :worker, [__MODULE__]} -> [hero]
      end)

    GenServer.call(server, {:broadcast, enemies})
  end

  def control(_, _), do: {:error, %BadCommand{}}

  @doc """
  Get current hero position.
  """
  @spec position(GenServer.server()) :: Board.tile()
  def position(server), do: GenServer.call(server, :position)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    board = Keyword.fetch!(opts, :board)
    tile = Keyword.fetch!(opts, :tile)

    {:ok, %State{board: board, tile: tile}}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call({msg, _}, _from, %State{alive: false} = state) when msg in @actions do
    {:reply, {:error, :noop}, state}
  end

  @impl true
  def handle_call({:play, move}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)

    {:reply, {:ok, result}, %{state | tile: result}}
  end

  @impl true
  def handle_call({:broadcast, []}, _from, state) do
    {:reply, {:ok, :launched}, state}
  end

  @impl true
  def handle_call({:broadcast, enemies}, _from, state) do
    args = [state.tile, enemies]
    Task.Supervisor.async_nolink(Game.TaskSupervisor, __MODULE__, :stream_task, args)
    {:reply, {:ok, :launched}, state}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call({:attack, _}, _from, %State{alive: false} = state) do
    {:reply, @dead_status, state}
  end

  @impl true
  def handle_call({:attack, enemy_tile}, _from, state) do
    {living_status, state} =
      case Board.attack_distance?(state.tile, enemy_tile) do
        true -> {@dead_status, %{state | alive: false}}
        false -> {@alive_status, state}
      end

    {:reply, living_status, state}
  end

  @impl true
  def handle_call(:position, _from, state), do: {:reply, state.tile, state}

  @impl true
  def handle_info({task_ref, :done}, state) do
    Process.demonitor(task_ref, [:flush])
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _down_ref, :process, _pid, reason}, state) do
    Logger.warn("Task failed with reason #{reason}", tag: "attack")
    {:noreply, state}
  end

  @spec stream_task(Board.tile(), list()) :: :done
  def stream_task(tile, enemies) do
    opts = [ordered: false]

    stream =
      Task.Supervisor.async_stream_nolink(
        Game.TaskSupervisor,
        enemies,
        GenServer,
        :call,
        [{:attack, tile}],
        opts
      )

    Stream.run(stream)
    :done
  end
end
