#include("../phase2/graph.jl")

function new_min_span_tree(graph :: AbstractGraph{T}, verbose:: Bool) where T 
    #liste de liens dans le minimum spanning tree
    new_edges=Vector{Edge}()

    # Ordonnement des liens par poids croissants
    graph_edges = edges(graph)
    sort!(graph_edges, by=e -> e.weight)

    # Pour chaque lien,
    for edge in graph_edges
        if verbose
            println("Searching...")
            show(edge)
        end

        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        root1=find_root(node1)
        root2=find_root(node2)

        #connection de deux composantes
        if root1!=root2
            if verbose
                println("merging components...")
            end

            #comparaison du rang et actualisation du pointeur vers la racine
            union_roots(root1,root2)

            #ajout de l arrete a l arbre
            push!(new_edges, edge)
        elseif verbose
            println("edge in only one component. On to next edge")
        end
    end

    #construction d arbre
    return( Graph("New minimal spanning tree of " * name(graph), nodes(graph), new_edges))
end

        
        

    

