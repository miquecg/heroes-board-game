defmodule HeroesWeb.ConnCase do
  @moduledoc """
  Setup and helpers for tests that require a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ConnTest
      import Plug.Conn

      alias Web.Router.Helpers, as: Routes

      @endpoint Web.Endpoint
      @game Routes.game_path(@endpoint, :index)
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
