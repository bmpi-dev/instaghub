defmodule Instaghub.Bucket do
  use Agent
  require Logger

  @name :kv
  @req_count :req

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def increase_req do
    Logger.debug "increase req"
    req = get(@req_count)
    put(@req_count, req + 1)
  end

  def decrease_req do
    Logger.debug "decrease req"
    req = get(@req_count)
    put(@req_count, req - 1)
  end

  def reset_req do
    put(@req_count, 0)
  end

  def get_req do
    req = get(@req_count)
    Logger.debug "req is #{req}"
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
