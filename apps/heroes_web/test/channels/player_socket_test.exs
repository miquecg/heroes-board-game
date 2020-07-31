defmodule Web.PlayerSocketTest do
  use HeroesWeb.ChannelCase, async: true

  alias Web.PlayerSocket, as: Socket

  test "Socket connection requires a valid token" do
    assert :error = connect(Socket, %{})
    assert :error = connect(Socket, %{"token" => "unsigned token"})
    assert :error = connect(Socket, %{"token" => sign_token("test", "wrong salt")})

    assert {:ok, _socket} = connect(Socket, %{"token" => sign_token("test")})
  end

  defp sign_token(data, salt \\ "player socket"), do: Phoenix.Token.sign(@endpoint, salt, data)
end
