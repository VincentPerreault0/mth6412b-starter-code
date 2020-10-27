
include("../phase2/graph.jl")

"""Fichier de test des fonctions read_stsp, plot_graph et des fichiers
    node.jl, edge.jl et graph.jl"""
function main()
    println("test")
    node1 = Node("Joe", 3.14, 1)
    println("node 1 is ok")
    node2 = Node("Steve", exp(1),node1)
    println(typeof(node1))
    println("node 2 is ok")
    node3 = Node("Jill", 4.12)
    println("node 3 is ok")
    edge1 = Edge(500, (node1, node2))
    edge2 = Edge(1000, (node2, node3))
    G = Graph("Ick", [node1, node2, node3], [edge1, edge2])
    show(node2)
    node4=find_root(node2)
    show(node4)
    print(node1==node2)
end

main()