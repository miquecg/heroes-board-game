defmodule Game.Board do
  @moduledoc """
  Board struct definition and utility functions to work with them.
  """

  alias __MODULE__
  alias Game.BoardRange

  @typedoc """
  Walkable board cell
  """
  @type tile :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  Cell where heroes cannot walk in.
  """
  @type wall :: tile

  @typedoc """
  A board is defined by:

  - `cols`: number of columns
  - `rows`: number of rows
  - `walls`: list of `t:wall/0`
  """
  @type t :: %__MODULE__{
          cols: pos_integer(),
          rows: pos_integer(),
          walls: list(wall)
        }

  @enforce_keys [:cols, :rows, :walls]

  defstruct @enforce_keys

  @typedoc """
  Allowed movements.
  """
  @type moves :: :up | :down | :left | :right

  @doc """
  Generate all tiles in a board.
  """
  @spec generate(t) :: list(tile)
  def generate(%Board{cols: cols, rows: rows, walls: walls}) do
    for x <- 0..(cols - 1), y <- 0..(rows - 1), {x, y} not in walls, do: {x, y}
  end

  @doc """
  Calculate an attack range given a tile.
  """
  @spec attack_range(tile, t) :: BoardRange.t()
  def attack_range({x, y}, %Board{cols: cols, rows: rows}) do
    x_min = max(x - 1, 0)
    x_max = min(x + 1, cols - 1)
    y_min = max(y - 1, 0)
    y_max = min(y + 1, rows - 1)

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
  defp validate(%{from: current, to: {x, y} = next}, %Board{cols: cols, rows: rows, walls: walls})
       when is_integer(x) and is_integer(y) do
    cond do
      x < 0 or x >= cols -> current
      y < 0 or y >= rows -> current
      next in walls -> current
      true -> next
    end
  end
end
