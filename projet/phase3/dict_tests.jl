include("../phase2/graph.jl")
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

dict_edges=Dict{Node, Vector{Edge}}()
dict_nodes=Dict{Node, Vector{Node}}()
for node in nodes(g3)
    dict_edges[node]=Edge[]
    dict_nodes[node]=Node{typeof(node)}[]
end
# Calcul des listes d adjacence
for edge in edges(g3)
    node1=nodes(edge)[1]
    node2=nodes(edge)[2]
    push!(dict_nodes[node1],node2)
    push!(dict_nodes[node2],node1)
    push!(dict_edges[node1],edge)
    push!(dict_edges[node2],edge)
end 
for node in nodes(g3)
    println("adjaceny of")
    show(node)
    for node_tmp in dict_nodes[node]
        show(node_tmp)
    end
end