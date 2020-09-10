defmodule GameTest do
  use ExUnit.Case

  alias Game.Hero

  @app :heroes_server

  setup do
    Application.stop(@app)
    :ok = Application.start(@app)
  end

  test "When a player joins the game a hero is created and registered" do
    opts = [board: GameBoards.Test2x2w1, player_spawn: :first_tile]
    game = start_supervised!({Game, [name: :test_game] ++ opts})

    assert count_heroes() == 0

    player_id = GenServer.call(game, :join)
    hero = Game.hero(player_id)

    assert count_heroes() == 1
    assert {0, 1} = Hero.position(hero)
  end

  defp count_heroes, do: Registry.count(Game.Registry)
end
