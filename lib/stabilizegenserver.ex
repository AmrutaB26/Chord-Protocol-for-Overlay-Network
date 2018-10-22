defmodule STABILIZEGENSERVER do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__,[], name: :stabilize)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    JOIN.stabilize()
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1)
  end
end
