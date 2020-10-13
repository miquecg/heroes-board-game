defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  import Mox

  @game GameMock

  setup context do
    opts = [
      game: @game,
      reconnect_timeout: Map.get(context, :timer, 0)
    ]

    {:ok, child} = start_supervised({Web.ChannelWatcher, opts})

    [watcher_pid: child]
  end

  setup context do
    @game
    |> stub(:position, fn _ -> {0, 0} end)
    |> allow(self(), context.watcher_pid)

    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  setup :verify_on_exit!

  test "Remove hero after leaving channel", %{socket: socket} do
    reply = expect_call_remove_once()

    leave_channel(socket)

    assert_receive ^reply, 200
  end

  test "Remove hero after closing socket", %{socket: socket} do
    reply = expect_call_remove_once()

    close_socket(socket)

    assert_receive ^reply, 200
  end

  test "Do not remove hero when player reconnects", %{socket: socket} do
    expect_not_call_remove()

    leave_channel(socket)
    {:ok, _, _} = join(socket, @topics.board)

    :timer.sleep(200)
  end

  describe "Timer set after channel shutdown" do
    @describetag timer: 20

    setup %{socket: socket} do
      {msg, fun} = remove_callback()
      stub(@game, :remove, fun)

      shutdown_channel(socket)

      [reply: msg]
    end

    test "is cancelled when player reconnects", %{socket: socket, reply: reply} do
      {:ok, _, _} = join(socket, @topics.board)

      refute_receive ^reply, 400
    end

    test "continues when other player joins", %{reply: reply} do
      {:ok, _, _} =
        "second_player"
        |> player_socket()
        |> join(@topics.board)

      assert_receive ^reply, 400
    end
  end

  defp remove_callback do
    parent = self()
    msg = {make_ref(), :done}

    fun = fn _ ->
      send(parent, msg)
      :ok
    end

    {msg, fun}
  end

  defp shutdown_channel(socket) do
    Process.flag(:trap_exit, true)
    Process.exit(socket.channel_pid, :shutdown)
  end
end
