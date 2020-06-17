defmodule HeroesWeb.BrowserCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require a real web browser.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import HeroesWeb.Router.Helpers

      @endpoint HeroesWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, _} = Application.ensure_all_started(:wallaby)
    :ok
  end
end
