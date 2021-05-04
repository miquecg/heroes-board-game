import Config

config :heroes_cluster, :topologies,
  k8s: [
    strategy: Cluster.Strategy.Kubernetes,
    config: [
      kubernetes_selector: System.get_env("LIBCLUSTER_KUBERNETES_SELECTOR"),
      kubernetes_node_basename: System.get_env("LIBCLUSTER_KUBERNETES_NODE_BASENAME")
    ]
  ]

config :heroes_web, Web.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
