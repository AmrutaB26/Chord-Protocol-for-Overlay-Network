defmodule CHORD do
  use GenServer

  ## ------------------------ Callback functions ----------------------- ##

  def start_link(num) do
    nodeName = "Node_" <> Integer.to_string(num)
    hashName = :crypto.hash(:sha, "Node_" <> Integer.to_string(num)) |> Base.encode16
    :ets.insert(:table, {nodeName, hashName}) # -------------------------- try to change
    GenServer.start_link(__MODULE__,[hashName,%{}], name: String.to_atom(nodeName))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:fingerTable, val}, _from, state) do
    [hash,_] = Enum.at(state,1)
    state = [hash,val]
    {:reply, state,state}
  end

  def handle_call({:update,hashKey},_from,state) do
    [hashName,key] = state
    state = [hashName,key | hashKey]
    IO.inspect state
    {:reply, state,state}
  end

  # ---------------------- Network Creation ------------------------ ##

  def createNetwork(numNodes) do
    hashList = sortHash(numNodes)
    m = :math.log2(numNodes) |> Float.floor |> round
    createFingerTables(m, hashList)
  end

  def sortHash(numNodes) do
    Enum.map(1..numNodes, fn x ->
      [{_,list}] = :ets.lookup(:table,"Node_" <> Integer.to_string(x))
      list
    end)
    |> Enum.sort()
  end

  def createFingerTables(m, hashList) do
    Enum.map(hashList, fn x->
      index = Enum.find_index(hashList, fn y -> y == x end)
      map = %{}
      map = fingerTable(0, map, index, m, hashList)
      GenServer.call(String.to_atom("Node_" <> Integer.to_string(index+1)), {:fingerTable, map})
    end)
  end

  def fingerTable(i, map, index, m, hashList) do
      if(i == m+1) do
        map
      else
        start = rem(index + round(:math.pow(2,i)), round(:math.pow(2,m)))
        successor = if(i < m) do
          Enum.at(hashList, index+1)   ## ------------------- if to be stored based on index????
        else
          Enum.at(hashList, 0)
        end
        map = Map.put(map, start, successor)
        fingerTable(i+1, map, index, m, hashList)
      end
  end

  def getSuccessorNode(key,nodeList) do
    node =  Enum.find(nodeList, fn x -> :crypto.hash(:sha, x) > key end)
    if(node == nil) do
      Enum.at(nodeList,0)
    else
     node
    end
   end

   def randomString(length) do
     if(length != 0) do
       Enum.random(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'])
     end
   end

   def stringGenerator(numRequests,nodeList) do
    Enum.map(1..2*numRequests, fn x->
      value = randomString(12)
      key = :crypto.hash(:sha, value)
      node = getSuccessorNode(key,nodeList)
      #storeKeyinNode(node,key)
      #@valueList = [@valueList | value]
    end)
  end
end
