defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  setup :socket_mock

  describe "Topic game:board" do
    setup context do
      socket = subscribe_and_join!(context.socket, @topics.board)

      [socket: socket, player_id: socket.assigns.player_id]
    end

    test "presence joining channel", %{player_id: id} do
      assert_push "presence_state", %{}

      assert_broadcast "presence_diff", %{joins: %{^id => %{metas: metas}}, leaves: %{}}
      assert [%{phx_ref: _, x: 5, y: 3}] = metas
    end

    test "presence leaving channel", %{player_id: id} = context do
      leave_channel(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end

    test "presence closing socket", %{player_id: id} = context do
      close_socket(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end
  end

  describe "Topic game:lobby" do
    setup context do
      @endpoint.subscribe(@topics.lobby)
      {:ok, _, socket} = join(context.socket, @topics.board)

      [socket: socket, player_id: socket.assigns.player_id]
    end

    test "presence joining channel", %{player_id: id} do
      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{^id => _metas},
          leaves: %{}
        },
        topic: "game:lobby"
      }
    end

    test "presence leaving channel", %{player_id: id} = context do
      leave_channel(context.socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => _metas}
        },
        topic: "game:lobby"
      }
    end

    test "presence closing socket", %{player_id: id} = context do
      close_socket(context.socket)

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

  @tag name: "removed_player"
  test "Join crashes if hero is not found in the board", context do
    assert {:error, %{reason: "join crashed"}} = join(context.socket, @topics.board)
  end

  test "Unauthorized join on a second connection for same player", %{socket: socket} do
    {:ok, _, _} = join(socket, @topics.board)

    assert {:error, %{reason: "unauthorized"}} = join(socket, @topics.board)
  end

  defp socket_mock(%{socket: socket} = context) do
    assigns = %{
      player_id: Map.get(context, :name, "test_player"),
      game: GameMock
    }

    [socket: Phoenix.Socket.assign(socket, assigns)]
  end
end
