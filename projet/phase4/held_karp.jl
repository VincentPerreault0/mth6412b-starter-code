include("../phase3/prim.jl")
include("../phase3/priority_queue.jl")
include("../phase2/graph.jl")

"""Algorithme de création de tous les sous graphes possibles à partir d'un graphe donné"""
function sub_graph(graphe :: AbstractGraph)

end

"""Algorithme de Held et Karp pour la résolution du
problème de voyageur de commerce"""
function held_karp(graph :: AbstractGraph, s :: AbstractNode)
    if (s in nodes(graph))==false
        return
    end
    nb_nodes = nb_nodes(graph)
    
end