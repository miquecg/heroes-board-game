defmodule Web.AcceptanceTest do
  use HeroesWeb.BrowserCase
  @moduletag :browser

  import Wallaby.Query, only: [button: 1, css: 2]

  @game game_path(@endpoint, :index)

  feature "User visits the game URL and the board grid is loaded", %{session: session} do
    session
    |> visit(@game)
    |> assert_has(css("#grid .cell", count: 48))
    |> assert_has(css(".cell.wall", count: 7))
  end

  feature "User clicks the start button and their hero appears in the board grid", %{
    session: session
  } do
    session
    |> visit(@game)
    |> refute_has(hero_on_the_grid())
    |> click(button("Start"))
    |> assert_has(hero_on_the_grid(count: 1))
  end

  @sessions 2
  feature "Other players' heroes appear in the board grid when loaded", %{
    sessions: [user1, user2]
  } do
    user1
    |> visit(@game)
    |> click(button("Start"))

    user2
    |> visit(@game)
    |> click(button("Start"))

    user2
    |> assert_has(hero_on_the_grid(count: 2))
  end

  defp hero_on_the_grid(opts \\ []), do: css("#grid .hero", opts)
end
