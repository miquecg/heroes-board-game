defmodule HeroesWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that rely on Phoenix Channels interaction.
  """

  use ExUnit.CaseTemplate

  import Phoenix.ChannelTest

  alias Web.PlayerSocket

  @endpoint Web.Endpoint

  using do
    quote do
      import HeroesWeb.ChannelCase
      import Phoenix.ChannelTest

      @endpoint Web.Endpoint

      @topics %{
        board: "game:board",
        lobby: "game:lobby"
      }
    end
  end

  setup %{test: test_name} do
    assigns = %{
      player_id: Atom.to_string(test_name),
      hero: test_name
    }

    opts = [
      name: test_name,
      board: nil,
      tile: {5, 3}
    ]

    [
      socket: socket(PlayerSocket, nil, assigns),
      hero_pid: start_supervised!({Game.Hero, opts}),
      player_id: assigns.player_id
    ]
  end

  def leave_channel(socket) do
    Process.unlink(socket.channel_pid)

    ref = leave(socket)
    assert_reply ref, :ok, %{}, 100
  end

  def close_socket(socket) do
    Process.unlink(socket.channel_pid)
    :ok = close(socket)
  end
end
