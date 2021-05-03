defmodule Cluster.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies()]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec topologies :: keyword()
  defp topologies, do: Application.fetch_env!(:heroes_cluster, :topologies)
end
