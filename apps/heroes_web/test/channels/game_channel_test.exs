defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  alias Web.GameChannel
  alias Web.PlayerSocket, as: Socket

  setup do
    id = HeroesServer.join()
    [assigns: %{player_id: id}]
  end

  setup context do
    {:ok, _, socket} = join_channel(context.assigns)

    %{socket: socket}
  end

  test "Channel pushes presence state to the client when joining" do
    assert_push "presence_state", %{}
  end

  test "Channel broadcasts joins when they happen", context do
    %{player_id: id} = context.assigns

    assert_broadcast "presence_diff", %{joins: %{^id => _metas}, leaves: %{}}
  end

  test "Channel join crashes with an invalid player_id" do
    assigns = %{player_id: "invalid"}
    assert {:error, %{reason: "join crashed"}} = join_channel(assigns)
  end

  test "Player cannot join channel using different sockets", context do
    assert {:error, %{reason: "unauthorized"}} = join_channel(context.assigns)
  end

  defp join_channel(assigns) do
    Socket
    |> socket(nil, assigns)
    |> subscribe_and_join(GameChannel, "game:lobby")
  end
end
