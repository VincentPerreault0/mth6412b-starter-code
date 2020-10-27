include("../phase2/graph.jl")
include("priority_queue.jl")

"""" fonction qui prend un graphe et une source et renvoie
un minimal spanning tree par l algorithme de Prim"""

function Prim(graph :: AbstractGraph, s :: AbstractNode)
    if not s in nodes(graph)
        println("la source doit etre un noeud du graphe")
        return
    end
    #initialisation de la liste d'arretes de l arbre
    new_edges=Vector{Edge}()

    #Initialisation du dictionnaire des noeuds et listes d'adjacence
    for node in nodes(graph)
        node.weight=10000
        node.parent=nothing
        node.neighbours=Node{typeof(data(node))}[]
    end

    # Calcul des listes d adjacence
    for edge in edges(graph)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        add_neighbour(node1, node2)
        add_neighbour(node2, node1)
    end 

    #initialisation 
    s.weight=0
    q=PriorityQueue{Node}()
    for node in nodes(graph)
        push!(q, node)
    end

    #initialisation de la file de priorite des arretes
    p=priorityQueue{Edge}()

    #Boucle
    while nb_items(q)>0
        #on sort un noeud de minweight minimal
        u=popfirst!(q)

        #on ajoute l arrete concernee aux arretes du minimum spanning tree
        egde_tmp=popfirst!(p)
        if u in nodes(edge_tmp) && parent(u) in nodes(edges_tmp)
            p_tmp=priorityQueue{Edge}(edge_tmp)
            while not (u in nodes(edge_tmp) && parent(u) in nodes(edges_tmp))
                edge_tmp=popfirst!(p)
                push!(p_tmp, edge_tmp)
            end
            for edge in p_tmp
                push!(p, edge)
            end
        end
        push!(new_edges, edge_tmp)

        #on actualise les valeurs des noeuds voisins 
        for v in neigbours(u)
            for edge in edges(graph)
                if u in edges(node) && v in edges(node) && weight(edge)<minweight(v)
                    v.parent=u
                    v.minweight=weight(edge)
                    push!(p, edge)
                end
                break
            end
        end
    end
    g=Graph("Minimum Spanning tree of"*graph(name), nodes(graph), new_edges)
end
