include("../phase2/graph.jl")
include("priority_queue.jl")

"""" fonction qui prend un graphe et une source et renvoie
un minimal spanning tree par l algorithme de Prim"""

function prim(graph :: AbstractGraph, s :: AbstractNode)
    if (s in nodes(graph))==false
        return
    end

    #initialisation de la liste d'arretes de l arbre
    new_edges=Vector{Edge}()

    #Initialisation du dictionnaire des noeuds et listes d'adjacence
    #for node in nodes(graph)
    #    node.minweight=10000
    #    node.parent=nothing
    #    node.neighbours=Node{typeof(data(node))}[]
    #end

    # Calcul des listes d adjacence
    for edge in edges(graph)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        add_neighbour(node1, node2)
        add_neighbour(node2, node1)
    end 

    #initialisation 
    s.minweight=0
    q=PriorityQueue{Node}()
    for node in nodes(graph)
        add_item!(q, node)
    end

    #initialisation de la file de priorite des arretes
    p=priorityQueue{Edge}()

    #Boucle
    while nb_items(q)>0
        #on sort un noeud de minweight minimal
        u=popfirst!(q, Node)

        #on ajoute l arrete correspondante aux arretes du minimum spanning tree
        egde_tmp=popfirst!(p,u)
        add_item!(new_edges, edge_tmp)

        #on actualise les valeurs des noeuds voisins 
        for v in neigbours(u)
            if contains_item(q,v)
                for edge in edges(graph)
                    if u in edges(node) && v in edges(node) && weight(edge)<minweight(v)
                        v.parent=u
                        v.minweight=weight(edge)
                        add_item!(p, edge)
                    end
                    break
                end
            end
        end
    end
    g=Graph("Minimum Spanning tree from Prim alg of"*graph(name), nodes(graph), new_edges)
end
