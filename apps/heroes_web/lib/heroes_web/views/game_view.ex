defmodule HeroesWeb.GameView do
  use HeroesWeb, :view

  alias Game.Board

  def rows(%Board{v_range: v_range}), do: Enum.count(v_range)

  def reverse(min..max), do: max..min
end
