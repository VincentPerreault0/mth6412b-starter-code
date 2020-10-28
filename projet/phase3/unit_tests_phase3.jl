using Test
include("new_min_span_tree.jl")
#Test pour New Min Span Tree
println("Testing New Minimum Spanning Tree Kruskal Algorithm with range and depth")
println()

# Exemple vu en cours
nodeA = Node("a", nothing)
nodeB = Node("b", nothing)
nodeC = Node("c", nothing)
nodeD = Node("d", nothing)
nodeE = Node("e", nothing)
nodeF = Node("f", nothing)
nodeG = Node("g", nothing)
nodeH = Node("h", nothing)
nodeI = Node("i", nothing)

edge1 = Edge(4,(nodeA,nodeB))
edge2 = Edge(8,(nodeB,nodeC))
edge3 = Edge(7,(nodeC,nodeD))
edge4 = Edge(9,(nodeD,nodeE))
edge5 = Edge(14,(nodeD,nodeF))
edge6 = Edge(4,(nodeC,nodeF))
edge7 = Edge(2,(nodeC,nodeI))
edge8 = Edge(11,(nodeB,nodeH))
edge9 = Edge(8,(nodeA,nodeH))
edge10 = Edge(7,(nodeH,nodeI))
edge11 = Edge(1,(nodeG,nodeH))
edge12 = Edge(6,(nodeG,nodeI))
edge13 = Edge(2,(nodeF,nodeG))
edge14 = Edge(10,(nodeE,nodeF))

g3 = Graph("Class Example", [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH, nodeI], [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14])

#show(g3)
#println()

mst = NewMinSpanTree(g3, true)
println()

show(mst)
println()

@test nb_nodes(mst) == nb_nodes(g3)
@test nb_edges(mst) == 8
@test contains_edge(mst,edge1) == true
@test contains_edge(mst,edge2) == true || contains_edge(mst,edge9) == true  # ces 2 liens ont le même poids dans le graphe et, selon l'ordre utilisé dans sa construction explicite, l'algorithme de Kruskal va finir par en utiliser un et un seul pour son arbre de recouvrement minimal
@test contains_edge(mst,edge3) == true
@test contains_edge(mst,edge4) == true
@test contains_edge(mst,edge6) == true
@test contains_edge(mst,edge7) == true
@test contains_edge(mst,edge11) == true
@test contains_edge(mst,edge13) == true