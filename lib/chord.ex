defmodule CHORD do
  use GenServer

  ## ------------------------ Callback functions ----------------------- ##

  def start_link(num) do
    nodeName =  "Node_" <> Integer.to_string(num)
    hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(num)) |> Base.encode16
    :ets.insert(:table, {"Nodes", {hashValue, nodeName}})
    GenServer.start_link(__MODULE__,[hashValue,%{},[],""], name: String.to_atom("h_" <> hashValue))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_cast({:fingerTable, val}, state) do
    [hash,_,list,pred] = state
    state = [hash,val,list,pred]
    {:noreply ,state}
  end

  def handle_cast({:storeKey,hashKey},state) do
    [hashName,fingerTable,list,pred] = state
    state = [hashName,fingerTable, list ++ hashKey,pred]
    {:noreply,state}
  end

  def handle_cast({:pred,pred},state) do
    [hashName,table,list,_] = state
    state = [hashName,table,list,pred]
    {:noreply, state}
  end

  def handle_cast({:hopCount,hop},state) do
    [_,_,h,_] = state
    state = ["",%{},[hop | h],""]
    {:noreply, state}
  end

  #def handle_info({:stabilize},state) do
   # JOIN.stabilize()
   # {:noreply, state}
  #end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end

  # ---------------------- Network Creation ------------------------ ##

  def createNetwork() do
    list = :ets.lookup(:table,"Nodes")
    finalList = Enum.sort_by(list,&elem(&1,1))
    :ets.delete(:table, "Nodes")
    :ets.insert(:table, {"Nodes", finalList})
    createFingerTables()
    storePredecessor()
  end

  def checkStatus do
    nodes = :ets.lookup(:table,"Nodes")
    [{_,hashList}] = nodes
    Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      IO.inspect(GenServer.call(String.to_atom("h_"<>nodeId),{:getState}),limit: :infinity)
      #[_,list,_,_] = GenServer.call(String.to_atom("h_"<>nodeId),{:getState})
      #sorted_map = Enum.to_list(list) |> Enum.sort(fn({key1, _}, {key2, _}) -> key1 < key2 end)
      #IO.inspect([a,sorted_map,b,c] , limit: :infinity)
    end)
  end

  def storePredecessor() do
    nodeList = ROUTING.getNodeList
    numNodes = Enum.count(nodeList)
    GenServer.cast(String.to_atom("h_" <> Enum.at(nodeList, 0)) ,{:pred,Enum.at(nodeList, numNodes-1)})
    Enum.each(1..numNodes-1, fn x->
      pred = Enum.at(nodeList, x-1)
      nodeId = "h_" <> Enum.at(nodeList, x)
      GenServer.cast(String.to_atom(nodeId) ,{:pred,pred})
    end)
  end

  def truncateHash(hashValue) do
    {value,_} = Integer.parse(hashValue,16)
    Integer.to_string value
  end

  def generateListNodeIds() do
    nodes = :ets.lookup(:table,"Nodes")
    [{_,hashList}] = nodes
    nodeIds = Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      truncateHash(nodeId)
    end)
    max = Enum.map(nodeIds, fn x->
      String.to_integer x
    end)  |>  Enum.max()
    [nodeIds, max]
  end

  def createFingerTables() do
    [nodeIds, max] = generateListNodeIds()
    [{_,m}] = :ets.lookup(:table,"m")
    Enum.map(nodeIds,
    fn x->
      spawn(fn -> fingerTable(0, %{}, x,nodeIds, max,m) end)
    end)
  end

  def makeSize(value) do
    if(String.length(value) == 40 || String.length(value) > 40) do
      value
    else
      makeSize("0"<>value)
    end
  end

  def fingerTable(i, map, nodeId, list, max,m) do
    if(i == m) do
      value = Integer.to_string(String.to_integer(nodeId), 16)
      value = makeSize(value)
      node = String.to_atom("h_" <> value)
      [_,fingerTable,_,_] = GenServer.call(node,{:getState})
      if(!Map.equal?(map, fingerTable)) do
        GenServer.cast(node, {:fingerTable, map})
        storePredecessor()
      end
    else
      start = String.to_integer(nodeId) + round(:math.pow(2,i))
      index = rem(start, round(:math.pow(2,160)))
      successor =
        Enum.find(list, fn x ->
          index < String.to_integer(x)
        end)
        finalSuccessor =
        if(successor == nil) do
           String.to_integer(Enum.at(list,0))
          else
            String.to_integer(successor)
        end
        value = Integer.to_string(finalSuccessor,16)
        |> makeSize()
        s = Integer.to_string(start,16)
        |> makeSize()
      map = Map.put(map, s, value)
      fingerTable(i+1, map, nodeId, list, max,m)
      end
  end

  def randomString(length) do
    charList = Enum.map(1..length, fn _ ->
      Enum.random(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'])
    end)
    List.to_string(charList)
  end

  def stringGenerator(numNodes) do
    keyList = Enum.map(1..numNodes, fn _ ->
      value = randomString(12)
      key = :crypto.hash(:sha, value) |> Base.encode16
      spawn(fn -> getSuccessorWrapper(key) end)
      value
    end)
    :ets.insert(:table, {"Keys", keyList})
  end

  def getSuccessorWrapper(key) do
    node = getSuccessorNode(key)
    GenServer.cast(String.to_atom("h_" <> node), {:storeKey, [key]})
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
      key < x
      end)
    if(successor == nil) do
      Enum.at(nodeIds,0)
    else
      successor
    end
  end
end
