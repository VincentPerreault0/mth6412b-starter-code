using Test
include("graph.jl")

"""Tests pour les méthodes de Graph"""
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

show(g1)
println()

@test nb_nodes(g1) == 3
@test contains_node(g1,node3) == true
@test nb_edges(g1) == 2
@test contains_edge(g1,edge2) == true

g2 = Graph("g2", [node1, node2, node3], [edge1, edge2])

show(g2)
println()

@test name(g1) != name(g2)
@test nodes(g1) == nodes(g2)
@test edges(g1) == edges(g2)


"""Tests pour les méthodes de Graph"""
println("Testing Graph methods...")
println()




println("All tests complete!")