defmodule Web.ChannelWatcher do
  @moduledoc """
  Watches game channels activity to remove heroes when players quit the game.
  """

  use GenServer

  ## Client

  @doc """
  Start GenServer under supervision.

  Requires option `:timeout`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, non_neg_integer()}
  def init(opts), do: {:ok, Keyword.fetch!(opts, :timeout)}
end
