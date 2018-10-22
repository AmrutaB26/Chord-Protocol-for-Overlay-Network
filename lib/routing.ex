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
    IO.puts("Looking for keys")
    [{_,keyList}] = :ets.lookup(:table, "Keys")
    nodeList = getNodeList()
    GenServer.start_link(CHORD,["",%{},[],""], name: String.to_atom("main"))
    Enum.map(nodeList, fn x->
      spawn(fn -> sendRequest(numRequests,keyList,x)end)
    end)
    #IO.puts("Total number of hops = #{inspect Enum.sum(hopsList)}")
    #IO.puts("Average number of hops = #{inspect Enum.sum(hopsList)/numRequests}")
  end

  def hopsCount do
    [_,_,hop,_] = GenServer.call(String.to_atom("main"),{:getState})
    hop
  end

  def sendRequest(numRequests,keyList,node) do
    Enum.map(1..numRequests,fn x->
        key = :crypto.hash(:sha, Enum.random(keyList)) |> Base.encode16
        IO.puts()
        spawn(fn -> spawnRequests(key,node)end)
        Process.sleep(1000)
    end)
  end

  def timeout(numRequests) do
    Process.sleep(10)
    nodeList = getNodeList()
    hopsList = hopsCount()
    if(Enum.count(hopsList) >= Enum.count(nodeList)*numRequests) do
        hops = Enum.sum(hopsList)
        IO.inspect(hopsList,limit: :infinity)
        IO.puts("Average number of hops = #{inspect hops/(Enum.count(nodeList)*numRequests)}")
        System.halt(0)
    end
    timeout(numRequests)
  end

  def spawnRequests(key,startNode) do
    [n,h] = find_successor(key,startNode,0)
    GenServer.cast(:main,{:hopCount, h})
    #IO.puts("key #{inspect key} found at node #{inspect n} with hops #{inspect h}")
  end

  def find_successor(key,firstNode,hops) do
    #IO.puts "key = #{inspect key} , firstNode = #{inspect firstNode}"
        [_,fingerTable,_,_] = GenServer.call(String.to_atom("h_"<>firstNode),{:getState})
        {_,successor} = Enum.at(fingerTable,0)
        #IO.puts("hhhhhhhhh #{inspect firstNode} #{inspect hops} #{inspect key} #{inspect successor}")
        #key between first node and successor
        if(key > firstNode && key < successor) do
            #IO.puts "key between first node and successor"
            [successor,hops+1]
        # key less than start
        else

            if(firstNode > successor && (key > firstNode || key < successor)) do
                #IO.puts "key between first node and successor and node < succ #{inspect firstNode} #{inspect successor} #{inspect key}"
                [successor,hops+1]
            else
            # key more than start less than a node
                out =
                Enum.map(fingerTable, fn {_,v} ->
                    if v < key do
                    v
                    end
                end)
                #IO.inspect out
                finalNode =
                if(Enum.max(out) == nil) do
                    {_,v} = Enum.at(fingerTable,Enum.count(fingerTable)-1)
                    v
                else
                    Enum.max(out)
                end
                #IO.puts("next key find between #{inspect finalNode} from #{firstNode} #{inspect key}")
                find_successor(key, finalNode, hops+1)
             end

         end
     end
end
