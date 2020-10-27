include("../phase2/graph.jl")
include("priority_queue.jl")

function Prim(graph :: Graph, s :: Node)
    #Initialisation des noeuds 
    for node in nodes(graph)
        node.weight=10000
        node.parent=nothing
    end
    s.weight=0
    q=PriorityQueue{Edge}()

end
