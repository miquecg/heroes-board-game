defmodule Game.BoardRange do
  @moduledoc """
  A board subset represented as cell ranges.
  """

  alias __MODULE__

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

  def member?(%BoardRange{h: x_range, v: y_range}, {x, y}) do
    x in x_range and y in y_range
  end
end
