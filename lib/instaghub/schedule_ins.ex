defmodule Instaghub.INS.Schedule do
  use GenServer

  alias Instaghub.RedisUtil
  require Logger

  @ttl 60 * 60 * 12
  @rhx_gis "rhx_gis"
  @csrf "csrf"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    set_ins_token()
    Process.send_after(self(), :work, (@ttl - 60 * 20) * 1000)
  end

  defp set_ins_token() do
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
    headers = [referer: "https://www.instagram.com/", "user-agent": user_agent]
    base_url = 'https://www.instagram.com'
    res = HTTPoison.get!(base_url, headers)
    re = ~r'_sharedData = .*?;</script>'
    [[shared_data_json|_]|_] = Regex.scan(re, res.body)
    shared_data = shared_data_json |> String.replace("_sharedData =", "") |> String.replace(";</script>", "") |> Poison.decode!
    rhx_gis = shared_data |> Map.get("rhx_gis")
    csrf = shared_data |> Map.get("config") |> Map.get("csrf_token")
    if rhx_gis != nil do
      RedisUtil.setx(@rhx_gis, rhx_gis, @ttl)
      Logger.debug "get rhx_gis and store in redis with key rhx_gis"
    end
    if csrf != nil do
      RedisUtil.setx(@csrf, csrf, @ttl)
      Logger.debug "get csrf and store in redis with key csrf"
    end
  end
end
