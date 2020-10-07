defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  import Mox

  setup do
    expect(GameMock, :position, fn _ -> {5, 3} end)
    :ok
  end

  setup :verify_on_exit!

  describe "Topic game:board" do
    setup context do
      {:ok, %{hero: hero}, socket} = subscribe_and_join(context.socket, @topics.board)

      [socket: socket, hero: hero]
    end

    test "presence joining channel", %{hero: id} do
      assert_push "presence_state", %{}

      assert_broadcast "presence_diff", %{joins: %{^id => %{metas: metas}}, leaves: %{}}
      assert [%{x: 5, y: 3}] = metas
    end

    test "presence leaving channel", %{socket: socket, hero: id} do
      leave_channel(socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end

    test "presence closing socket", %{socket: socket, hero: id} do
      close_socket(socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end
  end

  describe "Topic game:lobby" do
    setup context do
      @endpoint.subscribe(@topics.lobby)
      {:ok, _, socket} = join(context.socket, @topics.board)

      [socket: socket, player: socket.assigns.player]
    end

    test "presence joining channel", %{player: id} do
      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{^id => _metas},
          leaves: %{}
        },
        topic: "game:lobby"
      }
    end

    test "presence leaving channel", %{socket: socket, player: id} do
      leave_channel(socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => _metas}
        },
        topic: "game:lobby"
      }
    end

    test "presence closing socket", %{socket: socket, player: id} do
      close_socket(socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => _metas}
        },
        topic: "game:lobby"
      }
    end
  end

  test "Player cannot join game on a second channel", %{socket: socket} do
    assert {:ok, _, _} = join(socket, @topics.board)

    Process.flag(:trap_exit, true)

    catch_exit do
      stub(GameMock, :position, fn _ -> {0, 0} end)
      join(socket, @topics.board)
    end
  end
end
