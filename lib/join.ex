defmodule JOIN do
  def startJoin(numNodes) do
    [nodeIds,_] = CHORD.generateListNodeIds()
    l = length(nodeIds)
    Enum.map(1..numNodes, fn x->
      #spawn(fn-> toSpawn(x,l) end)
      toSpawn(x,l)
    end)
  end

  def toSpawn(x,l) do
      [nodeIds, max] = CHORD.generateListNodeIds()
      nodeName =  "Node_" <> Integer.to_string(l+x)
      hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(l+x)) |> Base.encode16

      #start genserver process
      GenServer.start_link(CHORD,[hashValue,%{},[],""], name: String.to_atom("h_" <> hashValue))
      randomNode = Enum.random(ROUTING.getNodeList)

      #find successor
      [successor,_] = ROUTING.find_successor(hashValue, randomNode,0)
      nodeId = CHORD.truncateHash(hashValue)

      #update predecessors
      [_,_,_,pred] = GenServer.call(String.to_atom("h_" <> successor),{:getState})
      GenServer.cast(String.to_atom("h_" <> successor), {:pred,hashValue})
      GenServer.cast(String.to_atom("h_" <> hashValue), {:pred,pred})

      # update table
      [{_,list}] = :ets.lookup(:table,"Nodes")
      finalList = Enum.sort_by(list++[{"Nodes", {hashValue, nodeName}}],&elem(&1,1))
      :ets.delete(:table, "Nodes")
      :ets.insert(:table, {"Nodes", finalList})

      #generate fingerTable
      [{_,m}] = :ets.lookup(:table,"m")
      CHORD.fingerTable(0, %{}, nodeId, nodeIds, max,m)
      Process.sleep(1000)
      stabilize()
  end

  def stabilize() do
    CHORD.createFingerTables()
  end
end
