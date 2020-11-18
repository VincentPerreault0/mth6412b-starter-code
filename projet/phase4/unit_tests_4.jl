include("../phase2/graph.jl")
include("rsl.jl")
include("held_karp.jl")

using Test

node1=Node("1",5)
node2=Node("2", 10)
node3=Node("3", 22)
node4=Node("4", 11)
node5=Node("5", 11)
edge1=Edge(10.0, (node1,node2))
edge2=Edge(21.0, (node2,node3))
edge3=Edge(10.0, (node2,node4))
edge4=Edge(12.0, (node3,node5))
dict_edges=Dict{Node, Vector{Edge}}()
dict_edges[node2]=Vector{Edge}()
dict_edges[node2]=[edge2,edge3]
dict_edges[node3]=[edge4, edge2]
dict_edges[node4]=[edge3]
dict_edges[node5]=[edge4]
q=find_children(node2, dict_edges,Vector{Node{Int64}}())

@test popfirst!(q)==node2
@test popfirst!(q)==node3
@test popfirst!(q)==node5
@test popfirst!(q)==node4

graph=Graph("graph Test", [node1, node2,node3,node4,node5], [edge1,edge2,edge3,edge4])
q=rsl(graph, node1)

@test popfirst!(q)==node1
@test popfirst!(q)==node2

println("Testing preordre function...")
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

g = Graph("Class Example", [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH, nodeI], [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14])
q=rsl(g, nodeA)
@test popfirst!(q)==nodeA
@test popfirst!(q)==nodeB
@test popfirst!(q)==nodeC
@test popfirst!(q)==nodeI
@test popfirst!(q)==nodeF
@test popfirst!(q)==nodeG
@test popfirst!(q)==nodeH
@test popfirst!(q)==nodeD
@test popfirst!(q)==nodeE

println("Testing fonctions Held Karp")

sgraph = sub_graph(graph,node3)
sg_edges = edges(sgraph)
for i = 1 : length(sg_edges)
    @test !(node3 in(nodes(sg_edges[i])))
end
@test !(node3 in(nodes(sgraph)))

@test min_weight_edges(g,nodeC)==[edge6,edge7] || min_weight_edges(g,nodeC)==[edge7,edge6]

show(g)
sgraph = sub_graph(g,nodeB)
show(sgraph)
mst = prim(sgraph,nodeA)

mot = min_one_tree(g,nodeB)

@test nb_nodes(mot) == nb_nodes(g)
@test nb_edges(mot) == 8
@test contains_edge(mot,edge1) == true
@test contains_edge(mot,edge2) == true
@test contains_edge(mot,edge3) == true
@test contains_edge(mot,edge4) == true
@test contains_edge(mot,edge6) == true
@test contains_edge(mot,edge7) == true
@test contains_edge(mot,edge11) == true
@test contains_edge(mot,edge13) == true

println("Testing complete!")
