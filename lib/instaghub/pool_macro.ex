defmodule Instaghub.PoolMacro do
  defmacro pool(name, opt: opt) do
    quote do
      :poolboy.transaction(
        unquote(name),
        fn pid -> GenServer.call(pid, unquote(opt)) end,
        60_000)
    end
  end
end
