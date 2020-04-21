defmodule Hero do
  @moduledoc """
  Holds hero status (alive or dead) and current position on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer

  # Client

  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  # Server (callbacks)

  @impl true
  def init([]) do
    {:ok, []}
  end
end
