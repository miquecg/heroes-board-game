defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase

  alias Web.GameChannel
  alias Web.PlayerSocket, as: Socket

  @game :heroes_server

  setup do
    id = HeroesServer.join()
    [assigns: %{player_id: id}]
  end

  setup context do
    {:ok, _, socket} = join_game(context.assigns)

    %{socket: socket}
  end

  test "Channel pushes event presence_state to the client when joining" do
    assert_push "presence_state", %{}
  end

  test "Channel broadcasts event presence_diff to clients when joins happen", context do
    %{player_id: id} = context.assigns

    assert_broadcast "presence_diff", %{joins: %{^id => _metas}, leaves: %{}}
  end

  test "Player cannot join the channel with an expired id", context do
    Application.stop(@game)
    :ok = Application.start(@game)

    assert {:error, %{reason: "join crashed"}} = join_game(context.assigns)
  end

  defp join_game(assigns) do
    Socket
    |> socket(nil, assigns)
    |> subscribe_and_join(GameChannel, "game:lobby")
  end
end
