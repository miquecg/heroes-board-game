defmodule HeroesWeb.BrowserCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require a real web browser.
  """

  use ExUnit.CaseTemplate

  @game_server :heroes_server

  using do
    quote do
      use Wallaby.Feature

      import Web.Router.Helpers

      @endpoint Web.Endpoint
    end
  end

  setup _tags do
    Application.stop(@game_server)
    :ok = Application.start(@game_server)

    {:ok, _} = Application.ensure_all_started(:wallaby)
    :ok
  end
end
