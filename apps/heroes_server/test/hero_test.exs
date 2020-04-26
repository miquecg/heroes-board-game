defmodule HeroTest do
  use ExUnit.Case, async: true

  describe "A hero can move one tile" do
    setup do
      opts = [board: Board.Test4x4, tile: {1, 1}]
      [hero: start_supervised!({Hero, opts})]
    end

    test "up", %{hero: pid} do
      assert {1, 2} = Hero.move(pid, :up)
    end

    test "down", %{hero: pid} do
      assert {1, 0} = Hero.move(pid, :down)
    end

    test "right", %{hero: pid} do
      assert {2, 1} = Hero.move(pid, :right)
    end

    test "left", %{hero: pid} do
      assert {0, 1} = Hero.move(pid, :left)
    end
  end
end
