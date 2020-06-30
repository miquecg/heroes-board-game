defmodule HeroesServer do
  @moduledoc """
  The entrypoint to play the game.
  """

  use GenServer

  @typep state :: %__MODULE__.State{
           board_mod: module(),
           dice: function()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board_mod, :dice]

    defstruct @enforce_keys
  end

  ## Client

  @doc """
  Start the server entrypoint.

  Requires to be configured with
  `:board_mod` and `:player_start`.

  Optionally can receive a :name.
  """
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Join a player to the server creating a new hero.
  """
  @spec join() :: {pid(), Game.tile()}
  def join, do: GenServer.call(__MODULE__, :join)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    mod = Keyword.fetch!(opts, :board_mod)

    dice =
      case Keyword.fetch!(opts, :player_start) do
        :randomized -> &Enum.random/1
        :first_tile -> &Kernel.hd/1
      end

    {:ok, %State{board_mod: mod, dice: dice}}
  end

  @impl true
  def handle_call(:join, _from, %State{board_mod: board_mod, dice: dice} = state) do
    tiles = board_mod.tiles()
    start_pos = dice.(tiles)

    opts = [board: board_mod, tile: start_pos]
    {:ok, pid} = DynamicSupervisor.start_child(Game.HeroSupervisor, {Game.Hero, opts})

    {:reply, {pid, start_pos}, state}
  end
end
