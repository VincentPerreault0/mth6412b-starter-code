include("priority_queue.jl")
include("../phase2/graph.jl")

"""Fichier de test des fonctions de priority_queue et edge.jl"""
function main()
    println("test")
    node1 = Node("Joe", 3.14, 1)
    node2 = Node("Steve", exp(1),node1)
    node3 = Node("Jill", 4.12)
    edge1 = Edge(500, (node1, node2))
    edge2 = Edge(1000, (node2, node3))
    println(edge1==edge2)
    println(edge1<edge2)
    q=PriorityQueue([edge1, edge2])
    tmp=popfirst!(q)
    show(tmp)
    tmp2=popfirst!(q)
    show(tmp2)
end

main()