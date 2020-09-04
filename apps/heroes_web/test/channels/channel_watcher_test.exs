defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  setup :register_hero

  setup context do
    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  setup context do
    [ref: Process.monitor(context.hero_pid)]
  end

  test "Hero is removed time after leaving the channel", %{ref: ref} = context do
    leave_channel(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 150
  end

  test "Hero is removed time after closing the socket", %{ref: ref} = context do
    close_socket(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 150
  end
end
