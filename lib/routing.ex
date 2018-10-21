defmodule ROUTING do
  def getNodeList do
  nodes = :ets.lookup(:table,"Nodes")
  [{_,hashList}] = nodes
  Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      nodeId
      end)
end

def lookup(numRequests,numNodes) do
  IO.puts("keys : #{inspect :ets.lookup(:table, "Keys")}")
  IO.puts("Looking for keys")
  [{_,keyList}] = :ets.lookup(:table, "Keys")
  hopsList = Enum.map(1..numRequests,fn x->
      key = :crypto.hash(:sha, Enum.random(keyList)) |> Base.encode16
      nodeList = getNodeList()
      [n,h] = find_successor(key,Enum.at(nodeList,0),0)
      IO.puts("key #{inspect key} found at node #{inspect n} with hops #{inspect h}")
      h
  end)
  IO.puts("Total number of hops = #{inspect Enum.sum(hopsList)}")
  IO.puts("Average number of hops = #{inspect Enum.sum(hopsList)/numRequests}")
end

def find_successor(key,firstNode,hops) do
  [_,fingerTable,_] = GenServer.call(String.to_atom("h_"<>firstNode),{:getState})
  {_,successor} = Enum.at(fingerTable,0)

  #key between first node and successor
  if(key > firstNode && key < successor) do
      #IO.puts "key between first node and successor"
      [successor,hops+1]
  else
      # key less than start
    if(key < firstNode && hops == 0) do #why hops 0
      IO.puts "key less than start"
      [firstNode, hops+1]
    else
        # key more than start less than a node
      out =
      Enum.find(Map.to_list(fingerTable), fn {k,_} ->
        key < k
      end)

      # key more than max in fingertable
      if(out == nil) do
        max = Map.values(fingerTable) |> Enum.max()
        #IO.puts "key more than max in fingertable"
        find_successor(key, max, hops+1)
      else
        {tkey,successor_1} = out
        IO.puts "key more than start less than a node"
        IO.puts("ourKey = #{inspect key}, fingerTable start = #{inspect tkey}")
        [successor_1, hops+1]
      end
    end
  end
end
end
