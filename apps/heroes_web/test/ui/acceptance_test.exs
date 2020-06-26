defmodule HeroesWeb.AcceptanceTest do
  use HeroesWeb.BrowserCase, async: true
  @moduletag :browser

  import Wallaby.Query, only: [css: 2]

  @game game_path(@endpoint, :index)

  feature "When a browser opens the game endpoint the board grid is loaded", %{session: session} do
    session
    |> visit(@game)
    |> assert_has(css("#grid .cell", count: 48))
    |> assert_has(css(".cell.wall", count: 7))
  end
end
