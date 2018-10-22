defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  numNodes = 2
  numRequests = 2
  CHORDSUPERVISOR.start_link(numNodes)
  CHORD.createNetwork()
  GenServer.start_link(STABILIZEGENSERVER,[], name: :stabilize)
  JOIN.startJoin(5)
  CHORD.stringGenerator(50)
  CHORD.checkStatus
  #Process.sleep(250)
  IO.puts "looking up"
  ROUTING.lookup(numRequests)
  ROUTING.timeout(numRequests)
end
