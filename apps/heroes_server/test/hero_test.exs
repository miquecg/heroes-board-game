defmodule HeroTest do
  use ExUnit.Case, async: true

  @board Board.Test4x4
  @start_tile {1, 1}

  setup do
    opts = [board: @board, tile: @start_tile]
    [hero: start_supervised!({Hero, opts})]
  end

  describe "A hero can move one tile" do
    test "up", %{hero: pid} do
      assert {:ok, {1, 2}} = Hero.control(pid, :up)
    end

    test "down", %{hero: pid} do
      assert {:ok, {1, 0}} = Hero.control(pid, :down)
    end

    test "right", %{hero: pid} do
      assert {:ok, {2, 1}} = Hero.control(pid, :right)
    end

    test "left", %{hero: pid} do
      assert {:ok, {0, 1}} = Hero.control(pid, :left)
    end
  end

  test "Unknown commands return {:error, %BadCommand{}}", %{hero: pid} do
    assert {:error, %BadCommand{}} = Hero.control(pid, :doowap)
    assert {:error, %BadCommand{}} = Hero.control(pid, "up")
    assert {:error, %BadCommand{}} = Hero.control(pid, {1, 2})
  end
end
