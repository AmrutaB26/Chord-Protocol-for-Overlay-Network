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
    IO.inspect :ets.lookup(:table, "Keys")
    [{_,keyList}] = :ets.lookup(:table, "Keys")
    hopsList = Enum.map(1..numRequests,fn x->
        key = :crypto.hash(:sha, Enum.random(keyList)) |> Base.encode16
        nodeList = getNodeList()
        find_successor(key,Enum.at(nodeList,0))
    end)
    IO.puts("Total number of hops = #{inspect Enum.sum(hopsList)}")
    IO.puts("Average number of hops = #{inspect Enum.sum(hopsList)/numNodes}")
  end

  def find_successor(key,n) do
    [_,fingerTable,_] = GenServer.call(String.to_atom("h_"<>n),{:getState})
    {_,successor} = Enum.at(fingerTable,0)
    if(key > n && key < successor) do
        successor
    else
      if(key < n) do
        n
      else
        successor_1 =
        Enum.map(fingerTable, fn {k,v} ->
          if key <= k do
            v
          end
        end)
        find_successor(key , Enum.at(successor_1, Enum.count(successor_1)))
      end
    end
  end
end
