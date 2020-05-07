defmodule Game.BoardRange do
  @moduledoc """
  A board subset represented as cell ranges.
  """

  alias __MODULE__
  alias Game.Board

  @typedoc """
  - `h`: horizontal axis range
  - `v`: vertical axis range
  """
  @type t :: %__MODULE__{
          h: Range.t(non_neg_integer(), non_neg_integer()),
          v: Range.t(non_neg_integer(), non_neg_integer())
        }

  @enforce_keys [:h, :v]

  defstruct @enforce_keys

  @doc """
  Tell whether a tile is within a board range.
  """
  @spec member?(t, Board.tile()) :: boolean()
  def member?(%BoardRange{h: x_range, v: y_range}, {x, y}) do
    x in x_range and y in y_range
  end
end
