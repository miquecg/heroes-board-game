defmodule Game.Board do
  @moduledoc """
  Board struct definition and utility functions to work with them.
  """

  alias __MODULE__
  alias Game.BoardRange
  alias GameError.BadSize

  @typedoc """
  Walkable board cell
  """
  @type tile :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  Cell where heroes cannot walk in.
  """
  @type wall :: tile

  @opaque t :: %__MODULE__{
            x_max: non_neg_integer(),
            y_max: non_neg_integer(),
            walls: MapSet.t(wall)
          }

  @enforce_keys [:x_max, :y_max, :walls]

  defstruct @enforce_keys

  @typedoc """
  Allowed movements.
  """
  @type moves :: :up | :down | :left | :right

  @doc """
  Create a board struct from given options.

  Requires a positive number of `cols`, `rows`
  and optionally a list of `t:wall/0`.
  """
  @spec new(keyword()) :: t
  def new(opts) do
    %Board{
      x_max: fetch!(opts, :cols) - 1,
      y_max: fetch!(opts, :rows) - 1,
      walls: get(opts, :walls)
    }
  end

  @spec fetch!(keyword(), atom()) :: pos_integer()
  defp fetch!(opts, size) do
    value = Keyword.fetch!(opts, size)

    if is_integer(value) and value > 0 do
      value
    else
      raise BadSize, size: size, value: value
    end
  end

  @spec get(keyword(), :walls) :: MapSet.t(wall)
  defp get(opts, :walls) do
    walls = Keyword.get(opts, :walls, [])
    MapSet.new(walls)
  end

  @doc """
  Generate all tiles in a board.
  """
  @spec generate(t) :: list(tile)
  def generate(%Board{x_max: x_max, y_max: y_max, walls: walls}) do
    for x <- 0..x_max, y <- 0..y_max, {x, y} not in walls, do: {x, y}
  end

  @doc """
  Calculate an attack range given a tile.
  """
  @spec attack_range(tile, t) :: Game.board_range()
  def attack_range({x, y}, %Board{} = board) do
    x_min = max(x - 1, 0)
    x_max = min(x + 1, board.x_max)
    y_min = max(y - 1, 0)
    y_max = min(y + 1, board.y_max)

    %BoardRange{h: x_min..x_max, v: y_min..y_max}
  end

  @doc """
  Play a `move`.

  `tile` is the starting point.
  """
  @spec play(tile, moves, t) :: tile
  def play(tile, move, board) do
    tile
    |> compute(move)
    |> validate(board)
  end

  @spec compute(tile, moves) :: %{from: tile, to: {integer(), integer()}}
  defp compute({x, y} = current, move) do
    next =
      case move do
        :up -> {x, y + 1}
        :down -> {x, y - 1}
        :left -> {x - 1, y}
        :right -> {x + 1, y}
      end

    %{from: current, to: next}
  end

  @spec validate(%{from: tile, to: {integer(), integer()}}, t) :: tile
  defp validate(%{from: current, to: {x, y} = next}, %Board{
         x_max: x_max,
         y_max: y_max,
         walls: walls
       })
       when is_integer(x) and is_integer(y) do
    cond do
      x < 0 or x > x_max -> current
      y < 0 or y > y_max -> current
      next in walls -> current
      true -> next
    end
  end
end
