defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  setup :register_hero

  setup context do
    [ref: Process.monitor(context.hero_pid)]
  end

  setup context do
    start_supervised!({Web.ChannelWatcher, reconnect_timeout: 50})
    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  test "Hero is removed time after leaving the channel", %{ref: ref} = context do
    leave_channel(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 600
  end

  test "Hero is removed time after closing the socket", %{ref: ref} = context do
    close_socket(context.socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 600
  end
end
