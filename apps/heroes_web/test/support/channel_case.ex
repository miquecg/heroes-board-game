defmodule HeroesWeb.ChannelCase do
  @moduledoc """
  Setup and helpers for testing Channels.
  """

  use ExUnit.CaseTemplate

  import Phoenix.ChannelTest

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

  setup do
    assigns = %{
      game: GameMock,
      player: "test_player"
    }

    [socket: socket(Web.PlayerSocket, "test", assigns)]
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
