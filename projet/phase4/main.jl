include("../phase2/graph.jl")
include("held_karp.jl")
include("rsl.jl")

filenames = ["instances/stsp/bayg29.tsp",
            "instances/stsp/bays29.tsp",
            "instances/stsp/brazil58.tsp",
            "instances/stsp/dantzig42.tsp",
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

filenames3 = ["instances/stsp/bayg29.tsp",
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

  # Held et Karp (choisir entre max_w et max_w_lk)
  
  pi_mg = zeros(nb_nodes(graph))

  #tree_graph, max_wk = max_w(graph, 1.0, 10000, pi_mg, true, false)
  tree_graph, max_wk = max_w_lk(graph, 1.0, 1000, pi_mg, true, false)
  
  # Fonction get_tour ajoutée après heure limite
  println(max_wk)
  tour_graph = get_tour(graph, tree_graph)
  if is_tour(tour_graph)
    println("Test réussi")
  end
  println(total_weight(tour_graph))
  #reset_graph!(tour_graph)
  #println(degrees(tour_graph))
  #show(tour_graph)
  println()

  # RSL

  #for i = 1:10
  #  reset_graph!(graph)
  #  tour_graph = rsl(graph,nodes(graph)[i])

  #  println(rsl_graph_weight(graph, tour_graph))
  #  println()
  #end
end