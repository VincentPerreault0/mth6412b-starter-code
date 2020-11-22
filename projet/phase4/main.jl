include("../phase2/graph.jl")
include("held_karp.jl")

filenames = ["instances/stsp/dantzig42.tsp",
            "instances/stsp/fri26.tsp",
            "instances/stsp/gr17.tsp",
            "instances/stsp/gr21.tsp",
            "instances/stsp/gr24.tsp",
            "instances/stsp/gr48.tsp",
            "instances/stsp/hk48.tsp",
            "instances/stsp/swiss42.tsp"]

filenames2 = ["instances/stsp/fri26.tsp",
            "instances/stsp/gr17.tsp",
            "instances/stsp/gr21.tsp",
            "instances/stsp/gr24.tsp"]

for filename in filenames
  graph = create_graph_from_stsp_file(filename, false)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")

  pi_mg = zeros(nb_nodes(graph))

  tour_graph = max_w_lk(graph, 1.0, 1000, pi_mg, false, false)
  println(degrees(tour_graph))
  println()
end