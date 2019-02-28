defmodule Instaghub.RedisUtil do
  use GenServer

  @redis_uri Application.get_env(:instaghub, :redis_uri)
  @redis_name Application.get_env(:instaghub, :redis_name)
  @redis_ttl Application.get_env(:instaghub, :redis_ttl)

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Instaghub.RedisUtil)
  end

  def get(key) do
    res = command(["GET", key])
    case res do
      {:ok, value} -> value
      _ -> nil
    end
  end

  def setx(key, value, ttl \\ nil) do
    ttl = if ttl == nil do
      @redis_ttl
    else
      ttl
    end
    r = command(["SET", key, value, "ex", ttl])
    case r do
      {:ok, "OK"} -> :ok
      _ -> :error
    end
  end

  def set(key, value) do
    r = command(["SET", key, value])
    case r do
      {:ok, "OK"} -> :ok
      _ -> :error
    end
  end

  defp command(cmd) do
    GenServer.call(Instaghub.RedisUtil, {:cmd, cmd})
  end

  # Server (callbacks)

  @impl true
  def init(_config) do
    res = Redix.start_link(@redis_uri, name: @redis_name)
    case res do
      {:ok, conn} -> {:ok, conn}
      {:error, {:already_started, conn}} -> {:ok, conn}
    end
  end

  @impl true
  def handle_call({:cmd, command_list}, _from, conn) do
    res = Redix.command(conn, command_list)
    {:reply, res, conn}
  end

end
