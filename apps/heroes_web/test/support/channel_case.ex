defmodule HeroesWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that rely on Phoenix Channels interaction.
  """

  use ExUnit.CaseTemplate

  import Phoenix.ChannelTest

  alias Phoenix.Socket

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
    [socket: socket(Web.PlayerSocket)]
  end

  def dummy_hero(%{test: name, socket: socket}), do: dummy_hero(name, socket)
  def dummy_hero(name) when is_atom(name), do: dummy_hero(name, socket(Web.PlayerSocket))

  defp dummy_hero(name, socket) do
    assigns = %{
      player_id: Atom.to_string(name),
      hero: name
    }

    opts = [
      name: name,
      board: nil,
      tile: {5, 3}
    ]

    [
      socket: Socket.assign(socket, assigns),
      hero_pid: start_supervised!({Game.Hero, opts})
    ]
  end

  def register_hero(context) do
    id = HeroesServer.join()

    assigns = %{
      player_id: id,
      hero: HeroesServer.hero(id)
    }

    [
      socket: Socket.assign(context.socket, assigns),
      hero_pid: GenServer.whereis(assigns.hero)
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
