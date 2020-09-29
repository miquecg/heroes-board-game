defmodule GameMock do
  @moduledoc false
  @behaviour GameBehaviour

  @test_player "test_player"

  def join, do: join(nil, nil)

  @impl true
  def join(nil, nil), do: @test_player

  @impl true
  def remove(@test_player), do: :ok

  @impl true
  def play(_, _), do: raise("GameMock")

  @impl true
  def position(@test_player), do: {5, 3}
end
