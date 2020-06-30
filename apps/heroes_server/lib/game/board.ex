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

  @typedoc """
  A board specification.
  """
  @type t :: %__MODULE__{
          h_range: Range.t(0, non_neg_integer()),
          v_range: Range.t(0, non_neg_integer()),
          walls: MapSet.t(wall)
        }

  @enforce_keys [:h_range, :v_range, :walls]

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
    cols = fetch!(opts, :cols)
    rows = fetch!(opts, :rows)
    walls = Keyword.get(opts, :walls, [])

    %Board{
      h_range: 0..(cols - 1),
      v_range: 0..(rows - 1),
      walls: MapSet.new(walls)
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

  @doc """
  Generate all tiles in a board.
  """
  @spec generate(t) :: list(tile)
  def generate(%Board{h_range: h_range, v_range: v_range, walls: walls}) do
    for x <- h_range, y <- v_range, {x, y} not in walls, do: {x, y}
  end

  @doc """
  Calculate an attack range given a tile.
  """
  @spec attack_range(t, tile) :: Game.board_range()
  def attack_range(%Board{h_range: h_min..h_max, v_range: v_min..v_max}, {x, y}) do
    x_min = max(x - 1, h_min)
    x_max = min(x + 1, h_max)
    y_min = max(y - 1, v_min)
    y_max = min(y + 1, v_max)

    %BoardRange{h: x_min..x_max, v: y_min..y_max}
  end

  @doc """
  Play a `move`.

  `tile` is the starting point.
  """
  @spec play(t, tile, moves) :: tile
  def play(board, tile, move) do
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
         h_range: h_min..h_max,
         v_range: v_min..v_max,
         walls: walls
       })
       when is_integer(x) and is_integer(y) do
    cond do
      x < h_min or x > h_max -> current
      y < v_min or y > v_max -> current
      next in walls -> current
      true -> next
    end
  end
end
