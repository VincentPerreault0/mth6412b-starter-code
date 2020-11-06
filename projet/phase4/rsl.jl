include("../phase3/prim.jl")

""" fonction qui prend en entree un noeud, les listes d'adjacences d un arbre, et un vecteur de noeuds ordonne et rajouter au vecteur
ordonne les noeuds en preordre de cet arbre (parcours du noeud puis parcours des enfants)
Cette fonction modifie la liste d'adjcence au fur et a mesure pour parcourir chaque noeud une unique fois"""
function find_children(s:: Node{T}, dict_edges:: Dict{Node, Vector{Edge}}, q:: Vector{Node{T}}) where T
    push!(q,s)
    if length(dict_edges[s])==0
        return(q)
    else
        for edge in dict_edges[s]
            node1,node2=nodes(edge)
            if (node1==s)==false
                filter!(x -> x != edge, dict_edges[node1])
                q=find_children(node1,dict_edges,q)
            else 
                filter!(x -> x != edge, dict_edges[node2])
                q=find_children(node2,dict_edges,q) 
            end
        end
    end
    return(q)
end

""" fonction qui prend en entree un graphe et une racine et renvoie en vecteur une proposition de tournee pour le TSP lie 
a ce graphe
On utilise l algorithme de Prim pour construite un arbre de recouvrement minimal
Les arretes adjacentes de chaque noeud sont parcourues en ordre croissant des poids, du fait de l'ordre des arretes
renvoye par l algorithme de Prim"""
function rsl(graph::AbstractGraph, s::AbstractNode)
    mst=prim(graph,s)
    dict_edges=Dict{Node, Vector{Edge}}()
    for node in nodes(mst)
        dict_edges[node]=Edge[]
    end
    for edge in edges(mst)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        push!(dict_edges[node1],edge)
        push!(dict_edges[node2],edge)
    end
    q=find_children(s,dict_edges,Vector{typeof(s)}())
    return(q)
end

    




