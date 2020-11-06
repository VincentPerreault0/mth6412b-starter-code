#include("../phase2/graph.jl")
include("priority_queue.jl")

"""" fonction qui prend un graphe et une source et renvoie
un minimal spanning tree par l algorithme de Prim"""
function prim(graph :: AbstractGraph, s :: AbstractNode)
    if (s in nodes(graph))==false
        return
    end
    #initialisation des listes
    new_edges=Edge[]
    s.minweight=0
    q=PriorityQueue{Node}()
    p=PriorityQueue{Edge}()

    #initialisation des dictionnaires contenant les listes d adjacences des noeuds
    #et les arretes incidentes pour chaque noeud
    dict_edges=Dict{Node, Vector{Edge}}()
    dict_nodes=Dict{Node, Vector{Node}}()
    for node in nodes(graph)
        dict_edges[node]=Edge[]
        dict_nodes[node]=Node{typeof(node)}[]
        add_item!(q,node)
    end

    # Calcul des listes d adjacence
    for edge in edges(graph)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        push!(dict_nodes[node1],node2)
        push!(dict_nodes[node2],node1)
        push!(dict_edges[node1],edge)
        push!(dict_edges[node2],edge)
    end 

    #Boucle
    while nb_items(q)>0
        #on sort un noeud de minweight minimal
        u=popfirst!(q, Node)
        #on ajoute l arrete correspondante aux arretes du minimum spanning tree
        if (u==s)==false #si u ==s on est a la premiere iteration et p est vide
            tmp=popfirst!(p,u)
            push!(new_edges,tmp)
        end
        #on actualise les valeurs des noeuds voisins 
        for v in dict_nodes[u]
            if contains_item(q,v)==true
                for edge in dict_edges[v]
                    if u in nodes(edge) && v in nodes(edge) && weight(edge)<minweight(v)
                        v.parent=u
                        v.minweight=weight(edge)
                        add_item!(p,edge)
                    end
                end
            end
        end
    end
    return(Graph("Minimum Spanning tree from Prim alg of "*name(graph), nodes(graph), new_edges))
end
