defmodule Web.Presence do
  @moduledoc """
  Track player presence and hero position during the game.
  """

  use Phoenix.Presence,
    otp_app: :heroes_web,
    pubsub_server: Web.PubSub
end
