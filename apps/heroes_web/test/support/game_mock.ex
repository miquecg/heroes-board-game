defmodule GameMock do
  @moduledoc false
  @behaviour GameBehaviour

  @impl true
  def join(_, _), do: raise("GameMock")

  @impl true
  def remove(_), do: raise("GameMock")

  @impl true
  def play(_, _), do: raise("GameMock")

  @impl true
  def position("removed_player"), do: {}

  @impl true
  def position(_id), do: {5, 3}
end
