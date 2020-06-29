defmodule HeroesServer do
  @moduledoc """
  The entrypoint to play the game.
  """

  use GenServer

  @typep state :: %__MODULE__.State{
           board: module(),
           dice: function()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :dice]

    defstruct @enforce_keys
  end

  ## Client

  @doc """
  Start the server entrypoint.

  Requires to be configured with
  `:board` and `:start_tile`.
  """
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc """
  Join a player to the server creating a new hero.
  """
  @spec join() :: {pid(), Game.tile()}
  def join, do: GenServer.call(__MODULE__, :join)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    board = Keyword.fetch!(opts, :board)

    dice =
      case Keyword.fetch!(opts, :start_tile) do
        :randomized -> &Enum.random/1
        :first -> &Kernel.hd/1
      end

    {:ok, %State{board: board, dice: dice}}
  end

  @impl true
  def handle_call(:join, _from, %State{board: board, dice: dice} = state) do
    tiles = board.tiles()
    start = dice.(tiles)

    opts = [board: board, tile: start]
    {:ok, pid} = DynamicSupervisor.start_child(Game.HeroSupervisor, {Game.Hero, opts})

    {:reply, {:ok, {pid, start}}, state}
  end
end
