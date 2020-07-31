defmodule HeroesWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that rely on Phoenix Channels interaction.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest

      @endpoint Web.Endpoint
    end
  end
end
