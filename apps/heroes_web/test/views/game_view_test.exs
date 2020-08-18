defmodule Web.GameViewTest do
  use HeroesWeb.ConnCase, async: true

  import Web.GameView

  alias Game.Board

  test "Count rows of the board" do
    board = Board.new(rows: 3, cols: 1)
    assert count_rows(board) == 3

    board = Board.new(rows: 1, cols: 5)
    assert count_rows(board) == 1

    board = Board.new(rows: 6, cols: 4, walls: [{0, 0}, {1, 2}])
    assert count_rows(board) == 6
  end

  test "Reversing ranges" do
    assert 100..1 = reverse(1..100)
    assert 1..1 = reverse(1..1)
  end
end
