include("../phase2/graph.jl")
include("rsl.jl")

node1=Node("1",5)
node2=Node("2", 10)
node3=Node("3", 22)
node4=Node("4", 11)
edge1=Edge(10.0, (node1,node2))
edge2=Edge(21.0, (node2,node3))
edge3=Edge(10.0, (node2,node4))

dict_edges=Dict{Node, Vector{Edge}}()
dict_edges[node2]=[edge2,edge3]
q=find_children(node2, dict_edges,PriorityQueue{Node}())
for node in items(q)
    show(node)
end

graph=Graph("graph Test", [node1, node2,node3,node4], [edge1,edge2,edge3])

print("Testing preordre function...")
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
mst = prim(g, nodeA)

