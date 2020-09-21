defmodule Web.PlayerSocket do
  @moduledoc """
  Entrypoint for game clients connecting through Websocket.
  """

  use Phoenix.Socket

  require Logger

  @one_day_seconds 86_400

  channel "game:*", Web.GameChannel

  @impl true
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "player socket", token, max_age: @one_day_seconds) do
      {:ok, id} ->
        {:ok, assign(socket, player_id: id, game: Game)}

      {:error, reason} ->
        Logger.error("Error verifying token #{inspect(token)}", tag: "token_#{reason}")
        :error
    end
  end

  @impl true
  def connect(params, _socket) do
    Logger.error("Socket connection denied with params #{inspect(params)}", tag: "token_missing")
    :error
  end

  @impl true
  def id(_socket), do: nil
end
