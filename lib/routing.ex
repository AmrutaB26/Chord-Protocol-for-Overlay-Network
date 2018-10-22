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
  #IO.puts("keys : #{inspect :ets.lookup(:table, "Keys")}")
  IO.puts("Looking for keys")
  [{_,keyList}] = :ets.lookup(:table, "Keys")
  GenServer.start_link(CHORD,["",%{},[0]], name: String.to_atom("main"))
  hopsList = Enum.map(1..numRequests,fn x->
      key = :crypto.hash(:sha, Enum.random(keyList)) |> Base.encode16
      nodeList = getNodeList()
      [n,h] = find_successor(key,Enum.at(nodeList,0),0)
      GenServer.cast(:main,{:hopCount, h})
      IO.puts("key #{inspect key} found at node #{inspect n} with hops #{inspect h}")
      h
  end)
  hops = hopsCount()
  IO.puts("Average number of hops = #{inspect hops/numRequests}")
  #IO.puts("Total number of hops = #{inspect Enum.sum(hopsList)}")
  #IO.puts("Average number of hops = #{inspect Enum.sum(hopsList)/numRequests}")
end

def hopsCount do
  [_,_,hop] = GenServer.call(String.to_atom("main"),{:getState})
  Enum.at(hop,0)
end

def find_successor(key,firstNode,hops) do
  [_,fingerTable,_] = GenServer.call(String.to_atom("h_"<>firstNode),{:getState})
  {_,successor} = Enum.at(fingerTable,0)

  #key between first node and successor
  [successorNode, hops] = if(key > firstNode && (firstNode > successor || (firstNode < successor && key < successor))) do
      IO.puts "key between first node and successor"
      [successor,hops+1]
  else
      # key less than start
    ans = if(key < firstNode && hops == 0) do
      IO.puts "key less than start"
      [firstNode, hops+1]
    else
        # key more than start less than a node
      out =
      Enum.map(fingerTable, fn {_,v} ->
          if v<key do
            v
          end
        end)
      find_successor(key, Enum.max(out), hops+1)
    end
    ans
  end
end
end
