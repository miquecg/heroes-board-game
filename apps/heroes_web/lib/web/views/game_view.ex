defmodule Web.GameView do
  use HeroesWeb, :view

  def count_rows(board) do
    rows = board.y_axis()
    Enum.count(rows)
  end

  def reverse(min..max), do: max..min
end
