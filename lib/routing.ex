defmodule ROUTING do

  def getNodeList do
  nodes = :ets.lookup(:table,"Nodes")
  [{_,hashList}] = nodes
  Enum.map(hashList, fn x->
      {_, {nodeId,_}} = x
      nodeId
      end)
  end

  def lookup(numRequests) do
    IO.puts "Performing lookup"
    [{_,keyList}] = :ets.lookup(:table, "Keys")
    nodeList = getNodeList()
    GenServer.start_link(CHORD,["",%{},[],""], name: String.to_atom("main"))
    Enum.map(nodeList, fn x->
        spawn(fn -> sendRequest(numRequests,keyList,x)end)
    end)
  end

  def hopsCount do
    [_,_,hop,_] = GenServer.call(String.to_atom("main"),{:getState})
    hop
  end

  def sendRequest(numRequests,keyList,node) do
    Enum.map(1..numRequests,fn _->
        key = :crypto.hash(:sha, Enum.random(keyList)) |> Base.encode16
        spawn(fn -> spawnRequests(key,node)end)
        Process.sleep(1000)
    end)
  end

  def timeout(numRequests) do
    Process.sleep(5)
    nodeList = getNodeList()
    hopsList = hopsCount()
    if(Enum.count(hopsList) >= Enum.count(nodeList)*numRequests) do
        hops = Enum.sum(hopsList)
        #IO.inspect(hopsList,limit: :infinity)
        IO.puts("Average number of hops = #{inspect hops/(Enum.count(nodeList)*numRequests)}")
        System.halt(0)
    else
        if(Enum.count(hopsList) >1000) do
        #IO.inspect(hopsList,limit: :infinity)
        #IO.puts("lists #{inspect Enum.count(hopsList)} #{inspect Enum.count(nodeList)} #{inspect numRequests}")
        end
    end
    timeout(numRequests)
  end

  def spawnRequests(key,startNode) do
    [_,h] = find_successor(key,startNode,0)
    GenServer.cast(:main,{:hopCount, h})
    #IO.puts("key #{inspect key} found at node #{inspect n} with hops #{inspect h}")
  end

  def find_successor(key,firstNode,hops) do
    [_,sorted_map,_,_] = GenServer.call(String.to_atom("h_"<>firstNode),{:getState})
    fingerTable = Enum.to_list(sorted_map) |> Enum.sort(fn({key1, _}, {key2, _}) -> key1 < key2 end)

    {_,successor} = Enum.at(fingerTable,0)
    if(key > firstNode && key < successor) do
        [successor,hops]
    else
        if(firstNode > successor && (key > firstNode || key < successor)) do
            [successor,hops]
        else
            out = Enum.map(fingerTable, fn {_,v} ->
                if v < key do
                    v
                end
            end)
            finalNode = if(Enum.max(out) == nil) do
                maxlist = Enum.map(fingerTable, fn {_,val} ->
                val
                end)
                Enum.max(maxlist)
            else
                Enum.max(out)
            end
                find_successor(key, finalNode, hops+1)
            end
        end
    end
end
