defmodule Web.GameViewTest do
  use HeroesWeb.ConnCase, async: true

  import Web.GameView
  alias Game.Board

  test "Count how many rows the board has" do
    board = Board.new(rows: 3, cols: 1)
    assert rows(board) == 3

    board = Board.new(rows: 1, cols: 5)
    assert rows(board) == 1

    board = Board.new(rows: 6, cols: 4, walls: [{0, 0}, {1, 2}])
    assert rows(board) == 6
  end

  test "Reversing ranges" do
    assert 100..1 = reverse(1..100)
    assert 1..1 = reverse(1..1)
  end

  test "Plot into the grid from player coordinates" do
    {0, 0}
    |> grid_plot()
    |> (&assert(grid_values(&1) == ["1", "-1"])).()

    {3, 0}
    |> grid_plot()
    |> (&assert(grid_values(&1) == ["4", "-1"])).()

    {0, 3}
    |> grid_plot()
    |> (&assert(grid_values(&1) == ["1", "-4"])).()

    {3, 3}
    |> grid_plot()
    |> (&assert(grid_values(&1) == ["4", "-4"])).()

    {5, 7}
    |> grid_plot()
    |> (&assert(grid_values(&1) == ["6", "-8"])).()
  end

  defp grid_values(css) do
    css
    |> List.flatten()
    |> Enum.filter(fn string -> Integer.parse(string) != :error end)
  end
end
