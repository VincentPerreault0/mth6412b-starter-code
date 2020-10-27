include("priority_queue.jl")
include("../phase2/graph.jl")

"""Fichier de test des fonctions de priority_queue et edge.jl et node.jl"""
function main()
    println("test")
    node1 = Node("Joe", 5.0, 1)
    node1.minweight=10
    node2 = Node("Steve", 5.0, node1)
    node2.minweight=2
    show(node2.parent)
    node3 = Node("Jill", 4.12)
    edge1 = Edge(500.0, (node1, node2))
    edge2 = Edge(500.0, (node2, node3))
    println(edge1<edge2)
    println(node1<node2)
    q=PriorityQueue([node1, node2])
    tmp=popfirst!(q)
    show(tmp)
    tmp2=popfirst!(q)
    show(tmp2)
    graph = Graph("Ick", [node1, node2, node3], [edge1, edge2])
    add_node!(graph, node3)
    println("add node works")
    #show(graph)
    for node in nodes(graph)
        node.neighbours=Node{typeof(data(node))}[]
    end
    for edge in edges(graph)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        add_neighbour(node1, node2)
        add_neighbour(node2, node1)
    end
    
    #Test de Priority Queue popfirst!(p, node)
    node1 = Node("Joe", 5.0, 1)
    node1.minweight=10
    node2 = Node("Steve", 5.0, node1)
    node2.minweight=2
    show(node2.parent)
    node3 = Node("Jill", 4.12)
    edge1 = Edge(500.0, (node1, node2))
    edge2 = Edge(500.0, (node2, node3))
    p=PriorityQueue([edge2, edge1])
    tmp=popfirst!(p)
    show(tmp)
    push!(p, tmp)
    show(node2.parent)
    tmp2=popfirst!(p, node2)
    show(tmp2)
end

main()