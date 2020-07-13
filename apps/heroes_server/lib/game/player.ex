defmodule Game.Player do
  @moduledoc false

  @enforce_keys [:id, :coords]

  defstruct @enforce_keys

  @typedoc """
  Struct containing game state
  of an active player.
  """
  @type t :: %__MODULE__{
          id: HeroesServer.player_id(),
          coords: Game.tile()
        }
end
