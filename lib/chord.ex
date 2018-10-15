defmodule CHORD do
  @list1 []
  use GenServer

  ## ------------------------ Callback functions ----------------------- ##

  def start_link(num) do
    #@list1 ["sjdhk"]
    IO.inspect @list1
    nodeName = "Node_" <> Integer.to_string(num)
    hashName = :crypto.hash(:sha, "Node_" <> Integer.to_string(num))
    GenServer.start_link(__MODULE__,[hashName,[]], name: String.to_atom(nodeName))
  end

  def init(state) do
    IO.inspect state
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:update,hashKey},_from,state) do
    [hashName,key] = state
    state = [hashName,key | hashKey]
    {:reply, state,state}
  end

  def fingerTable do

  end
  def lookup do

  end
end
