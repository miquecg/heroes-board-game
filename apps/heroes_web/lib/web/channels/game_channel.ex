defmodule Web.GameChannel do
  use HeroesWeb, :channel

  def join("game:lobby", _message, socket) do
    {:ok, socket}
  end
end
