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
    |> stub(:subscribe, fn _, _ -> :ok end)
    |> allow(self(), context.watcher_pid)

    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  setup :verify_on_exit!

  describe "Expect one single call to Game.remove/1 when" do
    setup do
      {msg, fun} = remove_callback()

      @game
      |> expect(:remove, fn _ -> :ok end)
      |> stub(:remove, fun)

      [reply: msg]
    end

    test "client leaves channel", %{socket: socket, reply: reply} do
      leave_channel(socket)

      refute_receive ^reply, 200
    end

    test "socket is closed", %{socket: socket, reply: reply} do
      close_socket(socket)

      refute_receive ^reply, 200
    end
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
