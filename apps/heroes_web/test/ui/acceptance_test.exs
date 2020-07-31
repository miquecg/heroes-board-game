defmodule Web.AcceptanceTest do
  use HeroesWeb.BrowserCase
  @moduletag :browser

  import Wallaby.Query, only: [button: 1, css: 2]

  @game Routes.game_path(@endpoint, :index)

  setup context do
    if context[:join] do
      Enum.each(sessions(context), fn user ->
        user
        |> visit(@game)
        |> click(button("Start"))
      end)
    end

    :ok
  end

  feature "User visits the game URL and the board grid is loaded", %{session: user} do
    user
    |> visit(@game)
    |> assert_has(css("#grid .cell", count: 48))
    |> assert_has(css(".cell.wall", count: 7))
    |> assert_has(button("Start"))
  end

  feature "User clicks the start button and their hero appears in the board grid", %{
    session: user
  } do
    user
    |> visit(@game)
    |> refute_has(active_heroes())
    |> click(button("Start"))
    |> assert_has(active_heroes(count: 1))
  end

  @tag :join
  @sessions 2
  feature "JavaScript client updates board as players join and leave the game", %{
    sessions: [player1, player2]
  } do
    assert_has(player1, active_heroes(count: 2))
    assert_has(player2, active_heroes(count: 2))

    :ok = Wallaby.end_session(player2)
    assert_has(player1, active_heroes(count: 1))
  end

  defp sessions(%{session: user}), do: [user]
  defp sessions(context), do: context.sessions

  defp active_heroes(opts \\ []), do: css("#grid .hero", opts)
end
