include("../phase2/graph.jl")
include("held_karp.jl")
include("rsl.jl")

filenamegr21 = "instances/stsp/gr21.tsp"
filename561 = "instances/stsp/pa561.tsp"
filenamebhp = "instances/tsp/instances/blue-hour-paris.tsp"

graph = create_graph_from_stsp_file(filenamebhp, false)
println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")

nbn = nb_nodes(graph)
randval = rand(1:nbn)
randnode = nodes(graph)[randval]
randedge = edges(graph)[randval]
pi = zeros(nbn)
pi2 = ones(nbn)

println("time subgraph :")
@time sub_graph(graph,randnode)

println("time min weight edges :")
@time min_weight_edges(graph,randnode)

println("time min_weight_edges2 :")
@time min_weight_edges2(graph,randnode)

println("time set_node_numbers :")
@time set_node_numbers!(graph)

println("time order_nodes :")
@time order_nodes!(graph)

println("time reset_graph :")
@time reset_graph!(graph)

println("time get_edge_node_nums :")
@time get_edge_node_nums(randedge)

println("time add_pi_graph :")
@time old_weights = add_pi_graph!(graph,pi2)

println("time sub_pi_graph :")
@time sub_pi_graph!(graph,old_weights)

println("time mst krusk :")
@time find_minimum_spanning_tree(graph, false)

println("time mst prim")
@time prim(graph, randnode)

println("time min_one_tree :")
@time min_one_tree(graph,randnode, true, false)

reset_graph!(graph)

println("time w_one_trees :")
@time w_one_trees(graph, pi, true, false)
