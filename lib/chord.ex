defmodule CHORD do
  use GenServer

  ## ------------------------ Callback functions ----------------------- ##

  def start_link(num) do
    nodeName =  "Node_" <> Integer.to_string(num)
    hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(num)) |> Base.encode16
    :ets.insert(:table, {"Nodes", {hashValue, nodeName}})
    GenServer.start_link(__MODULE__,[hashValue,%{},[]], name: String.to_atom("h_" <> hashValue))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:fingerTable, val}, _from, state) do
    [hash,_,list] = state
    state = [hash,val,list]
    {:reply,  state ,state}
  end

  def handle_call({:storeKey,hashKey},_from,state) do
    [hashName,fingerTable,list] = state
    state = [hashName,fingerTable, list ++ [hashKey]]
    {:reply, state,state}
  end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update,hashKey},_from,state) do
    [hashName,key] = state
    state = [hashName,key | hashKey]
    {:reply, state,state}
  end

  # ---------------------- Network Creation ------------------------ ##

  def createNetwork(numNodes) do
    IO.puts "Creating network"
    list = :ets.lookup(:table,"Nodes")
    finalList = Enum.sort_by(list,&elem(&1,1))
    :ets.delete(:table, "Nodes")
    :ets.insert(:table, {"Nodes", finalList})
    createFingerTables(numNodes)
  end

  def checkStatus do
    nodes = :ets.lookup(:table,"Nodes")
    [{_,hashList}] = nodes
    Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      IO.inspect GenServer.call(String.to_atom("h_"<>nodeId),{:getState})
    end)
  end

  def truncateHash(hashValue) do
    {value,_} = Integer.parse(hashValue,16)
    Integer.to_string value
  end

  def createFingerTables(numNodes) do
    nodes = :ets.lookup(:table,"Nodes")
    [{_,hashList}] = nodes
    nodeIds = Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      truncateHash(nodeId)
    end)

    max = Enum.map(nodeIds, fn x->
      String.to_integer x
    end)  |>  Enum.max()

    Enum.map(nodeIds,
    fn x->
      fingerTable(0, %{}, numNodes, x,nodeIds, max)
    end)
  end

  def fingerTable(i, map, numNodes, nodeId, list, max) do
    [{_,m}] = :ets.lookup(:table,"m")
    if(i == m) do
      value = Integer.to_string(String.to_integer(nodeId), 16)
      value = if(String.length(value) != 40) do
        "0"<>value
      else value
      end
      IO.inspect value
      node = String.to_atom("h_" <> value)
      GenServer.call(node, {:fingerTable, map})
    else
      IOString.to_integer(nodeId)
      start = String.to_integer(nodeId) + round(:math.pow(2,i))
      index = rem(start, max)
      successor =
        Enum.find(list, fn x ->
          index <= String.to_integer(x)
        end)
        finalSuccessor =
        if(successor == nil) do
           String.to_integer(Enum.at(list,0))
          else String.to_integer(successor)
        end
      map = Map.put(map, Integer.to_string(start,16), Integer.to_string(finalSuccessor,16))
      fingerTable(i+1, map, numNodes, nodeId, list, max)
      end
  end

  def randomString(length) do
    charList = Enum.map(1..length, fn x ->
      Enum.random(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'])
    end)
    List.to_string(charList)
  end

  def stringGenerator(numNodes) do
    keyList = Enum.map(1..2*numNodes, fn x ->
      value = randomString(12)
      key = :crypto.hash(:sha, value) |> Base.encode16
      node = getSuccessorNode(key)
      GenServer.call(String.to_atom("h_" <> node), {:storeKey, key})
      value
    end)
    :ets.insert(:table, {"Keys", keyList}) # if new table needed?????
  end

  def getSuccessorNode(key) do
    nodes = :ets.lookup(:table,"Nodes")
    [{_,hashList}] = nodes
    nodeIds = Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      nodeId
      end)
    successor =
      Enum.find(nodeIds, fn x ->
      key <= x
      end)
    if(successor == nil) do
      Enum.at(nodeIds,0)
    else
      successor
    end
  end
end
