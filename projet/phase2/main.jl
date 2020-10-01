include("minimum_spanning_tree.jl")

filenames = ["instances/stsp/bayg29.tsp",
            "instances/stsp/bays29.tsp",
            "instances/stsp/brazil58.tsp",
            "instances/stsp/brg180.tsp",
            "instances/stsp/dantzig42.tsp",
            "instances/stsp/fri26.tsp",
            "instances/stsp/gr17.tsp",
            "instances/stsp/gr21.tsp",
            "instances/stsp/gr24.tsp",
            "instances/stsp/gr48.tsp",
            "instances/stsp/gr120.tsp",
            "instances/stsp/hk48.tsp",
            "instances/stsp/pa561.tsp",
            "instances/stsp/swiss42.tsp"]

for filename in filenames
  graph = create_graph_from_stsp_file(filename, false)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")

  mst = find_minimum_spanning_tree(graph, false)
  println("Graph ", name(mst), " has ", nb_nodes(mst), " nodes and ", nb_edges(mst), " edges.")

  println()
end
