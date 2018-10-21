defmodule CHORD do
  use GenServer

  ## ------------------------ Callback functions ----------------------- ##

  def start_link(num) do
    nodeName =  "Node_" <> Integer.to_string(num)
    [{_,m}] = :ets.lookup(:table,"m")
    hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(num)) |> Base.encode16
    truncHashValue = truncateHash(hashValue,m)
    :ets.insert(:table, {"Nodes", {hashValue, nodeName,truncHashValue}})
    GenServer.start_link(__MODULE__,[hashValue,%{}], name: String.to_atom("h_" <> truncHashValue))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:fingerTable, val}, _from, state) do
    [hash, _] = state
    state = [hash,val]
    {:reply, state,state}
  end

  def handle_call({:update,hashKey},_from,state) do
    [hashName,key] = state
    state = [hashName,key | hashKey]
    {:reply, state,state}
  end

  # ---------------------- Network Creation ------------------------ ##

  def createNetwork(numNodes) do
    list = :ets.lookup(:table,"Nodes")
    finalList = Enum.sort_by(list,&elem(&1,1))
    :ets.delete(:table, "Nodes")
    :ets.insert(:table, {"Nodes", finalList})
    createFingerTables(numNodes)
  end

  def truncateHash(hashValue,m) do
    newHash = String.slice(hashValue,0..m-1)
    {value,_} = Integer.parse(newHash,16)
    Integer.to_string value
  end

  def createFingerTables(numNodes) do
    nodes = :ets.lookup(:table,"Nodes")
    IO.inspect nodes
    [{_,hashList}] = nodes
    nodeIds = Enum.map(hashList, fn x->
      {_, {_,_,nodeId}} = x
      String.to_integer nodeId
    end)
    max = Enum.max(nodeIds)
    Enum.map(nodeIds, fn x->
      map = fingerTable(0, %{}, numNodes, x,nodeIds, max)
      IO.inspect map
      #GenServer.call("h_" <> String.to_atom(x), {:fingerTable, map})
    end)
  end

  def fingerTable(i, map, numNodes, nodeId, list, max) do
    [{_,m}] = :ets.lookup(:table,"m")
    if(i == m) do
       map
    else
      start = rem(nodeId + round(:math.pow(2,i)), max)
      successor =
      if(start > max) do
        Enum.at(list, 0)
      else
        Enum.find(list, fn x ->
          start <= x
        end)
      end
      map = Map.put(map, start, successor)
      fingerTable(i+1, map, numNodes, nodeId, list, max)
      end
  end

  def randomString(length) do
    charList = Enum.map(1..length,
      Enum.random(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'])
    )
    List.to_string(charList)
  end
end
