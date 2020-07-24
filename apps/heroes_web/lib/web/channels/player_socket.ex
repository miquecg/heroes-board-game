defmodule Web.PlayerSocket do
  @moduledoc """
  Entrypoint for players connecting to the game through sockets.
  """

  use Phoenix.Socket

  require Logger

  channel "game:*", Web.GameChannel

  @impl true
  @one_day_seconds 86400
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "player socket", token, max_age: @one_day_seconds) do
      {:ok, id} ->
        {:ok, assign(socket, :player_id, id)}
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
