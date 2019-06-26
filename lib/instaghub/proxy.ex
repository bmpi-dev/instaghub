defmodule Instaghub.Proxy do
  use GenServer
  require Logger

  @name :proxy

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, 0, name: @name)
  end

  def get() do
    GenServer.call(@name, :get)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call(:get, _from, index) do
    proxies = if System.get_env("PROXYS") != nil do
      System.get_env("PROXYS") |> String.split(",")
    else
      nil
    end
    if proxies != nil do
      len = length(proxies)
      index = rem(index, len)
      {:reply, proxies |> Enum.at(index), index+1}
    else
      {:reply, nil, 0}
    end
  end

end
