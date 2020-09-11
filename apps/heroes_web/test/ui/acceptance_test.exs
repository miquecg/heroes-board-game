defmodule Web.AcceptanceTest do
  use HeroesWeb.BrowserCase
  @moduletag :browser

  import Wallaby.Query, only: [button: 1, css: 2]

  feature "User visits /game and an empty board is loaded", context do
    context.session
    |> visit(@game)
    |> refute_has(active_heroes())
    |> assert_has(button("Start"))
    |> assert_has(css("#grid .cell", count: 48))
    |> assert_has(css(".cell.wall", count: 7))
  end

  feature "User clicks start button and the hero appears in the board", context do
    context.session
    |> click_start()
    |> assert_has(active_heroes(count: 1))
  end

  feature "JavaScript client updates board when new players join and leave",
          %{session: player_1}
  do
    player_1
    |> click_start()
    |> assert_has(active_heroes(count: 1))

    {:ok, player_2} = Wallaby.start_session()
    click_start(player_2)

    assert_has(player_1, active_heroes(count: 2))
    assert_has(player_2, active_heroes(count: 2))

    :ok = Wallaby.end_session(player_2)

    assert_has(player_1, active_heroes(count: 1))
  end

  defp click_start(session) do
    session
    |> visit(@game)
    |> click(button("Start"))
  end

  defp active_heroes(opts \\ []), do: css("#grid .hero", opts)
end
