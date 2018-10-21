defmodule CHORDSUPERVISOR do
  use Supervisor

  def start_link(numNodes) do
    :ets.insert(:table, {"m", :math.log2(numNodes) |> Float.floor |> round})
    Supervisor.start_link(__MODULE__,[numNodes],name: __MODULE__)
  end

  ## -------------- Creating multiple GenServer processes ------------ ##

  def init(args) do
    children = Enum.map(1..hd(args), fn x ->
      worker(CHORD,[x],[id: x])
    end)
    Supervisor.init(children,strategy: :one_for_one)
  end

end
