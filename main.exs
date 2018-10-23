defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  numNodes = 100
  numRequests = 2
  CHORDSUPERVISOR.start_link(5)
  CHORD.createNetwork()
  GenServer.start_link(STABILIZEGENSERVER,[], name: :stabilize)
  JOIN.startJoin(numNodes)
  CHORD.stringGenerator(50)
  CHORD.checkStatus
  #Process.sleep(250)
  IO.puts "looking up"
  ROUTING.lookup(numRequests)
  ROUTING.timeout(numRequests)
end
