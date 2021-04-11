defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  import Mox

  @game GameMock

  setup do
    stub(@game, :position, fn _ -> {0, 0} end)
    :ok
  end

  setup :verify_on_exit!

  describe "Topic game:board" do
    setup context do
      if tile = context[:position] do
        expect(@game, :position, fn _ -> tile end)
      end

      :ok
    end

    setup context do
      {:ok, %{hero: hero}, socket} = subscribe_and_join(context.socket, @topics.board)

      [socket: socket, hero: hero]
    end

    @tag position: {5, 3}
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
      expect(@game, :remove, fn ^id -> :ok end)

      leave_channel(socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => %{metas: [%{logout: true}]}}
        },
        topic: "game:lobby"
      }
    end

    test "presence closing socket", %{socket: socket, player: id} do
      expect(@game, :remove, fn ^id -> :ok end)

      close_socket(socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => %{metas: [%{logout: true}]}}
        },
        topic: "game:lobby"
      }
    end
  end

  test "Player cannot join game on a second channel", %{socket: socket} do
    expect(@game, :remove, 0, fn _ -> :ok end)
    {:ok, _, _} = join(socket, @topics.board)

    Process.flag(:trap_exit, true)

    catch_exit do
      join(socket, @topics.board)
    end
  end

  test "Player cannot join when hero is no longer in the board", %{socket: socket} do
    expect(@game, :position, fn _ -> {} end)

    assert {:error, %{reason: "unauthorized"}} = join(socket, @topics.board)
  end
end
