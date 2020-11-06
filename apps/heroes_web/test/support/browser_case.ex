defmodule HeroesWeb.BrowserCase do
  @moduledoc """
  Setup and helpers for tests that use a browser.
  """

  use ExUnit.CaseTemplate

  @game_server :heroes_server

  using do
    quote do
      use Wallaby.Feature

      alias Web.Router.Helpers, as: Routes

      @endpoint Web.Endpoint
      @index Routes.game_path(@endpoint, :index)
    end
  end

  setup do
    Application.stop(@game_server)
    :ok = Application.start(@game_server)

    {:ok, _} = Application.ensure_all_started(:wallaby)
    :ok
  end
end
