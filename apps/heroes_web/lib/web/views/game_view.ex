defmodule Web.GameView do
  use HeroesWeb, :view

  alias Game.Board

  @cols_start 1
  @rows_end -1

  def rows(%Board{v_range: v_range}), do: Enum.count(v_range)

  def reverse(min..max), do: max..min

  def grid_plot({x, y}) do
    [@cols_start + x, @rows_end - y]
    |> Stream.map(&Integer.to_string/1)
    |> Stream.zip([:column, :row])
    |> Enum.map(&css_property/1)
  end

  defp css_property({value, :column}), do: ["grid-column:", value, ";"]
  defp css_property({value, :row}), do: ["grid-row:", "span 1 / ", value, ";"]
end
