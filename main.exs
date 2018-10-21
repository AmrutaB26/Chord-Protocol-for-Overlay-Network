defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  #:ets.new(:keys, [:named_table,:public])
  CHORDSUPERVISOR.start_link(10)
  #CHORD.createNetwork(10)
  CHORD.createNetwork(10)
end
