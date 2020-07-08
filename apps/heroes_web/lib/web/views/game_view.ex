defmodule Web.GameView do
  use HeroesWeb, :view

  alias Game.Board

  @cols_start 1
  @rows_end -1

  def rows(%Board{v_range: v_range}), do: Enum.count(v_range)

  def reverse(min..max), do: max..min

  def cartesian_to_grid({x, y}) do
    [@cols_start + x, @rows_end - y]
    |> Enum.map(&Integer.to_string/1)
    |> List.to_tuple()
  end
end
