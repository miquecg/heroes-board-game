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

  test "Conversion of cartesian coordinates to grid cells in the HTML layout" do
    assert cartesian_to_grid({0, 0}) == {"1", "-1"}
    assert cartesian_to_grid({3, 0}) == {"4", "-1"}
    assert cartesian_to_grid({0, 3}) == {"1", "-4"}
    assert cartesian_to_grid({3, 3}) == {"4", "-4"}
    assert cartesian_to_grid({5, 7}) == {"6", "-8"}
  end
end