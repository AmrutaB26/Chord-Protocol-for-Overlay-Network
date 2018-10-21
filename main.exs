defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  numNodes = 100
  CHORDSUPERVISOR.start_link(numNodes)
  CHORD.createNetwork(numNodes)
  CHORD.stringGenerator(numNodes)
  IO.puts "Status of nodes"
  CHORD.checkStatus
  ROUTING.lookup(10,numNodes)
end
