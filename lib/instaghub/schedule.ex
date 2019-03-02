defmodule Instaghub.Bucket.Schedule do
  use GenServer

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
    Instaghub.Bucket.reset_req
    Process.send_after(self(), :work, 2 * 1000)
  end
end
