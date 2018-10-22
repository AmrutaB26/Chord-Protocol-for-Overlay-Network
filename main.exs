defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  numNodes = 10
  CHORDSUPERVISOR.start_link(numNodes)
  CHORD.createNetwork()
  GenServer.start_link(STABILIZEGENSERVER,[], name: :stabilize)
  JOIN.startJoin(numNodes)
  CHORD.stringGenerator(numNodes)
  CHORD.checkStatus
  Process.sleep(250)
  #ROUTING.lookup(10,numNodes)
end
