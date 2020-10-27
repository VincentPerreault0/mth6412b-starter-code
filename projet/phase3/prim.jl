include("../phase2/graph.jl")
include("priority_queue.jl")

function Prim(graph :: Graph, s :: Node)
    #Initialisation des noeuds 
    for node in nodes(graph)
        node.weight=10000
        node.parent=nothing
    end
    s.weight=0
    q=PriorityQueue{Node}()
    p=PriorityQueue{Edge}()
    for node in nodes(graph)
        push!(q, node)
    end
    while !is_empty(q)
        #on sort un des noeuds noeud avec minweight minimal
        u=popfirst!(q)
        for edge in edges(graph)
            if u in nodes(edge)


end
