defmodule MAIN do
  [n,r] =Enum.map(System.argv, (fn(x) -> x end))
  :ets.new(:table, [:bag, :named_table,:public])
  numNodes = String.to_integer(n)
  numRequests = String.to_integer(r)
  numKeys = 5000
  CHORDSUPERVISOR.start_link(numNodes)
  IO.puts "Created #{inspect numNodes} nodes network"
  CHORD.createNetwork()
  IO.puts "Performing join and stabilizing network"
  #GenServer.start_link(STABILIZEGENSERVER,[], name: :stabilize)
  #JOIN.startJoin(5)
  #CHORD.checkStatus()
  CHORD.stringGenerator(numKeys)
  IO.puts "Keys generated"
  ROUTING.lookup(numRequests)
  ROUTING.timeout(numRequests)
end
