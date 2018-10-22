defmodule JOIN do
  def startJoin(numNodes) do
    IO.puts "hereeee"
    [nodeIds,_] = CHORD.generateListNodeIds()
    l = length(nodeIds)
    Enum.map(1..numNodes, fn x->
      [nodeIds, max] = CHORD.generateListNodeIds()
      nodeName =  "Node_" <> Integer.to_string(l+x)
      hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(l+x)) |> Base.encode16

      # update table
      [{_,list}] = :ets.lookup(:table,"Nodes")
      finalList = Enum.sort_by(list++[{"Nodes", {hashValue, nodeName}}],&elem(&1,1))
      :ets.delete(:table, "Nodes")
      :ets.insert(:table, {"Nodes", finalList})

      #start genserver process
      IO.puts "hereeee"
      GenServer.start_link(CHORD,[hashValue,%{},[],""], name: String.to_atom("h_" <> hashValue))
      randomNode = Enum.random(nodeIds) #-- decimal
      node = Integer.to_string(String.to_integer(randomNode),16) |> CHORD.makeSize()

      #find successor
      #[successor,_] = ROUTING.find_successor(hashValue, node,0)
      successor = CHORD.getSuccessorNode(hashValue)
      IO.inspect successor
      IO.inspect hashValue
      nodeId = CHORD.truncateHash(hashValue)

      #generate fingerTable
      [{_,m}] = :ets.lookup(:table,"m")
      CHORD.fingerTable(0, %{}, nodeId, nodeIds, max,m)  # ----hardcoded

      #update predecessors
      [_,_,_,pred] = GenServer.call(String.to_atom("h_" <> successor),{:getState})
      GenServer.cast(String.to_atom("h_" <> successor), {:pred,hashValue})
      GenServer.cast(String.to_atom("h_" <> hashValue), {:pred,pred})
    end)
  end

  def stabilize() do
    [{_,m}] = :ets.lookup(:table,"m")
    [nodeIds, max] = CHORD.generateListNodeIds()
    IO.puts "stabilize"
    Enum.map(nodeIds, fn x->
      trial(x, nodeIds, max,m)
    end)
  end

  def trial(x, nodeIds, max,m) do
    CHORD.fingerTable(0,%{},x, nodeIds, max,m)  # ----hardcoded
  end
end
