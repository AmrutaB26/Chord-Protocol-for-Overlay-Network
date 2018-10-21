defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  CHORDSUPERVISOR.start_link(100)
  CHORD.createNetwork(100)
  CHORD.stringGenerator(100)
  CHORD.checkStatus
  ROUTING.lookup(10,100)
end
