defmodule Web.AcceptanceTest do
  use HeroesWeb.BrowserCase
  @moduletag :browser

  import Wallaby.Query, only: [button: 1, css: 1, css: 2]

  feature "User visits /game and the board is loaded without heroes", context do
    context.session
    |> visit(@game)
    |> assert_has(button("Start"))
    |> assert_has(css("#grid .cell", count: 48))
    |> assert_has(css(".cell.wall", count: 7))
    |> assert_heroes(0)
  end

  feature "User clicks start button and a hero appears in the board", context do
    context.session
    |> click_start()
    |> assert_heroes(1)
  end

  @sessions 2
  feature "JavaScript client updates board when players join and leave",
          %{sessions: [player_1, player_2]} do
    click_start(player_1)
    click_start(player_2)

    assert_heroes(player_1, 2)
    assert_heroes(player_2, 2)

    :ok = Wallaby.end_session(player_2)

    assert_heroes(player_1, 1)
  end

  defp click_start(session) do
    session
    |> visit(@game)
    |> click(button("Start"))
  end

  defp assert_heroes(parent, 0), do: assert_has(parent, css("#grid .hero", count: 0))

  defp assert_heroes(parent, number) do
    find(parent, css("#grid .hero-cells"), fn heroes ->
      heroes
      |> assert_has(css(".hero", count: number))
      |> assert_has(css(".hero.player", count: 1))
    end)
  end
end
