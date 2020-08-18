defmodule HeroesServer do
  @moduledoc """
  The entrypoint to play the game.
  """

  use GenServer

  @typedoc """
  Unique identifier for every active
  player in the server.

  26 characters binary string encoded
  in base 32 hex.
  """
  @type player_id :: <<_::208>>

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
  `:board` and `:player_spawn`.

  Optionally can receive a `:name`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Join a player to the server creating a new hero.
  """
  @spec join() :: player_id
  def join, do: GenServer.call(__MODULE__, :join)

  @doc """
  Registered name of player's hero.
  """
  @spec hero_name(player_id) :: {:via, module(), term()}
  def hero_name(player_id), do: {:via, Registry, {HeroesServer.Registry, player_id}}

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    board = Keyword.fetch!(opts, :board)

    dice =
      case Keyword.fetch!(opts, :player_spawn) do
        :randomized -> &Enum.random/1
        :first_tile -> &Kernel.hd/1
      end

    {:ok, %State{board: board, dice: dice}}
  end

  @impl true
  def handle_call(:join, _from, %State{board: board, dice: dice} = state) do
    player_id = generate_id()
    tiles = board.tiles()

    opts = [
      name: hero_name(player_id),
      board: board,
      tile: dice.(tiles)
    ]

    {:ok, _pid} = DynamicSupervisor.start_child(Game.HeroSupervisor, {Game.Hero, opts})

    {:reply, player_id, state}
  end

  @spec generate_id :: player_id
  defp generate_id do
    random_bytes = :crypto.strong_rand_bytes(16)
    Base.hex_encode32(random_bytes, padding: false)
  end
end
