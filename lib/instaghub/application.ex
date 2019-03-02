defmodule Instaghub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config_ins do
    [
      {:name, {:local, :ins_api_pool}},
      {:worker_module, Instaghub.Ins},
      {:size, 5}
    ]
  end

  defp poolboy_config_redis do
    [
      {:name, {:local, :redis_pool}},
      {:worker_module, Instaghub.RedisUtil},
      {:size, 5},
      {:max_overflow, 2}
    ]
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Instaghub.Repo,
      # Start the endpoint when the application starts
      InstaghubWeb.Endpoint,
      # Starts a worker by calling: Instaghub.Worker.start_link(arg)
      # {Instaghub.Worker, arg},
      Instaghub.Bucket,
      Instaghub.Bucket.Schedule,
      :poolboy.child_spec(:ins_api_pool, poolboy_config_ins()),
      :poolboy.child_spec(:redis_pool, poolboy_config_redis())
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Instaghub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    InstaghubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
