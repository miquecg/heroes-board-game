defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer

  require Logger

  alias Game.BoardRange
  alias GameError.BadCommand

  @moves [:up, :down, :left, :right]
  @actions [:play, :broadcast]

  @alive_status :alive
  @dead_status :dead

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Game.tile(),
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

  `pid` is the hero reference.
  `cmd` is of type `t:Game.moves/0`
  or atom `:attack`.

  Returns `{:ok, tile}`, `{:ok, :launched}`
  or `{:error, :noop}` when hero is dead and
  cannot execute any command.

  For invalid commands returns exception
  `GameError.BadCommand` in the error tuple.
  """
  @spec control(GenServer.server(), term()) ::
          {:ok, tile | :launched}
          | {:error, error}
        when tile: Game.tile(), error: :noop | %BadCommand{}
  def control(pid, cmd)

  def control(pid, cmd) when cmd in @moves, do: GenServer.call(pid, {:play, cmd})

  def control(pid, :attack) do
    children = Supervisor.which_children(Game.HeroSupervisor)

    enemies =
      Enum.flat_map(children, fn
        {_, ^pid, :worker, [__MODULE__]} -> []
        {_, hero, :worker, [__MODULE__]} -> [hero]
      end)

    GenServer.call(pid, {:broadcast, enemies})
  end

  def control(_, _), do: {:error, %BadCommand{}}

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
  def handle_call({:broadcast, []}, _from, %State{} = state) do
    {:reply, {:ok, :launched}, state}
  end

  @impl true
  def handle_call({:broadcast, enemies}, _from, %State{tile: tile} = state) do
    args = [tile, enemies]
    Task.Supervisor.async_nolink(Game.TaskSupervisor, __MODULE__, :stream_task, args)
    {:reply, {:ok, :launched}, state}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call({:attack, _}, _from, %State{alive: false} = state) do
    {:reply, @dead_status, state}
  end

  @impl true
  def handle_call({:attack, enemy}, _from, %State{board: board, tile: tile} = state) do
    attack_range = board.attack_range(tile)

    {living_status, state} =
      case BoardRange.member?(attack_range, enemy) do
        true -> {@dead_status, %{state | alive: false}}
        false -> {@alive_status, state}
      end

    {:reply, living_status, state}
  end

  @impl true
  def handle_info({task_ref, :done}, %State{} = state) do
    Process.demonitor(task_ref, [:flush])
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _down_ref, :process, _pid, reason}, %State{} = state) do
    Logger.warn("Attack failed with reason: #{inspect(reason)}", tag: :task_down)
    {:noreply, state}
  end

  @spec stream_task(Game.tile(), list()) :: :done
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
