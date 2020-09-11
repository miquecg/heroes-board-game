defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  setup :start_hero
  setup :monitor

  setup context do
    timeout = Map.get(context, :reconnect, 50)
    start_supervised!({Web.ChannelWatcher, reconnect_timeout: timeout})
    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  test "Hero is removed after leaving the channel", %{ref: ref} = context do
    leave_channel(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 600
  end

  test "Hero is removed after closing the socket", %{ref: ref} = context do
    close_socket(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 600
  end

  test "Hero is not removed when player reconnects during timeout", %{ref: ref} = context do
    leave_channel(context.socket)
    {:ok, _, _} = join(context.socket, @topics.board)

    refute_receive {:DOWN, ^ref, :process, _pid, :normal}, 1000
  end

  @tag reconnect: 100
  test "Tracks different heroes correctly", %{ref: ref, socket: first_socket} do
    leave_channel(first_socket)

    second_socket = start_hero()
    {:ok, _, _} = join(second_socket, @topics.board)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 600
  end

  defp start_hero do
    Web.PlayerSocket
    |> socket()
    |> start_hero()
  end

  defp start_hero(%{socket: socket}), do: [socket: start_hero(socket)]

  defp start_hero(socket) do
    id = Game.join()
    hero = Game.hero(id)

    assigns = %{
      player_id: id,
      hero: hero
    }

    Phoenix.Socket.assign(socket, assigns)
  end

  defp monitor(%{socket: socket}) do
    ref =
      socket.assigns.hero
      |> GenServer.whereis()
      |> Process.monitor()

    [ref: ref]
  end
end
