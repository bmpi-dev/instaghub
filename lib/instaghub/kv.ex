defmodule Instaghub.Bucket do
  use Agent
  require Logger

  @name :kv

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def increase_req(key) do
    Logger.debug "increase #{key} req"
    Agent.update(@name, fn map ->
      map_list = for {^key, v} <- map, do: Map.put(map, key, v + 1)
      map_list |> Enum.at(0)
    end)
  end

  def decrease_req(key) do
    Logger.debug "decrease #{key} req"
    Agent.update(@name, fn map ->
      map_list = for {^key, v} <- map do
          if v < 1 do
            Map.put(map, key, 0)
          else
            Map.put(map, key, v - 1)
          end
        end
      map_list |> Enum.at(0)
    end)
  end

  def reset_req(key) do
    req = get(key)
    Logger.debug "reset #{key} with 0, before is #{req}"
    put(key, 0)
  end

  def get_req(key) do
    req = get(key)
    Logger.debug "req #{key} is #{req}"
    req
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(key) do
    Agent.get(@name, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(key, value) do
    Agent.update(@name, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(key) do
    Agent.get_and_update(@name, &Map.pop(&1, key))
  end
end
