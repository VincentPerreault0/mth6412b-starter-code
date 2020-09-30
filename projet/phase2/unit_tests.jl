using Test
include("connected_component.jl")

# Tests pour les méthodes de Graph
println("Testing Graph methods...")
println()

node1 = Node("Joe", 3.14)
node2 = Node("Steve", exp(1))
node3 = Node("Jill", 4.12)
edge1 = Edge(500, (node1, node2))
edge2 = Edge(1000, (node2, node3))

g1 = create_empty_graph("g1",Float64)

@test name(g1) == "g1"
@test nb_nodes(g1) == 0
@test nb_edges(g1) == 0
@test contains_node(g1,node1) == false
@test contains_edge(g1,edge1) == false

add_node!(g1,node1)

@test nb_nodes(g1) == 1
@test contains_node(g1,node1) == true

add_edge!(g1,edge1)

@test nb_edges(g1) == 1
@test contains_edge(g1,edge1) == true
@test nb_nodes(g1) == 2
@test contains_node(g1,node2) == true

add_node!(g1,node3)
add_edge!(g1,edge2)

#show(g1)
#println()

@test nb_nodes(g1) == 3
@test contains_node(g1,node3) == true
@test nb_edges(g1) == 2
@test contains_edge(g1,edge2) == true

g2 = Graph("g2", [node1, node2, node3], [edge1, edge2])

#show(g2)
#println()

@test name(g1) != name(g2)
@test nodes(g1) == nodes(g2)
@test edges(g1) == edges(g2)


# Tests pour les méthodes de Connected Component
println("Testing ConnectedComponent methods...")
println()

cc1 = create_connected_component_from_node(node1)

@test name(cc1) == "Connected component containing node Joe"
@test nb_nodes(cc1) == 1
@test contains_node(cc1,node1) == true
@test nb_edges(cc1) == 0

@test contains_edge_nodes(cc1, edge2) == 0
@test contains_edge_nodes(cc1, edge1) == 1

cc2 = create_connected_component_from_node(node2)

@test contains_edge_nodes(cc2, edge1) == 1
@test contains_edge_nodes(cc2, edge2) == 1

merge_connected_components!(cc1,cc2,edge1)

@test nb_nodes(cc1) == 2
@test contains_node(cc1,node1) == true
@test contains_node(cc1,node2) == true
@test nb_edges(cc1) == 1
@test contains_edge(cc1,edge1) == true

@test contains_edge_nodes(cc1, edge1) == 2
@test contains_edge_nodes(cc1, edge2) == 1

cc3 = create_connected_component_from_node(node3)
merge_connected_components!(cc1,cc3,edge2)

#show(cc1)
#println()

@test name(g1) != name(cc1)
@test nodes(g1) == nodes(cc1)
@test edges(g1) == edges(cc1)


# Tests pour les méthodes de Connected Component
println("Testing Minimum Spanning Tree functions...")
println()



println("All tests complete!")