defmodule MAIN do
  :ets.new(:table, [:named_table,:public])
  SSUPERVISOR.start_link(10)
  CHORD.createNetwork(10);
end
