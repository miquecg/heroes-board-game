defmodule HeroesWeb.AcceptanceTest do
  use HeroesWeb.BrowserCase, async: true
  @moduletag :browser

  import Wallaby.Query, only: [css: 1, css: 2]

  @home page_path(@endpoint, :index)

  feature "There is a web", %{session: session} do
    session
    |> visit(@home)
    |> find(css("section"))
    |> assert_has(css("h1", text: "Welcome to Heroes Board Game"))
    |> assert_has(css("p", text: "Coming soon..."))
  end
end
