
include("graph.jl")
include("node.jl")
include("edge.jl")
include("read_stsp.jl")

"""Fonction qui lit un fichier stsp avec read_stsp puis utilise les fonctions des fichiers
    node.jl, edge.jl et graph.jl"""
function main(filename)
    # Utilisation de la fonction read_stsp
    graph_nodes, graph_edges = read_stsp(filename)

    # Définition des constantes
    dim_nodes = length(graph_nodes)
    edges = Edge[]
    dim_edges = length(graph_edges)

    # Création des nodes 
    if (dim_nodes != 0)
        nodes = Node{typeof(graph_nodes[1])}[]
        for node_ind in 1 : dim_nodes
            node = Node(string(node_ind), graph_nodes[node_ind])
            push!(nodes, node)
        end
    else
        # Si les nodes n'ont pas de data, on leur donne une data nulle : "nothing"
        nodes = Node{Nothing}[]
        for node_ind in 1 : dim_edges
            node = Node(string(node_ind), nothing)
            push!(nodes, node)
        end
    end

    # Création des edges à partir des nodes
    for i in 1 : dim_edges
        dim = length(graph_edges[i])
        for j in 1 : dim
            first_node = i
            second_node = graph_edges[i][j][1]
            edge_weight = graph_edges[i][j][2]
            edge = Edge(edge_weight, (nodes[first_node], nodes[second_node]))
            push!(edges, edge)
        end
    end

    # Création et affichage du graphe
    G = Graph("Test", nodes, edges)
    # show(G)
end

#main("D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/bayg29.tsp")
#main("D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/fri26.tsp")
#main("D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr120.tsp")
#main("D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/bays29.tsp")
#main("D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/swiss42.tsp")

file_names = ["D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/bayg29.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/bays29.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/brazil58.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/brg180.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/dantzig42.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/fri26.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr17.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr21.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr24.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr48.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/gr120.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/hk48.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/pa561.tsp",
            "D:/Poly_Montreal/Cours/MTH6412B/projet_part1/mth6412b-starter-code/instances/stsp/swiss42.tsp"]

for i = 1 : 14
    main(file_names[i])
    println(string("ok file number : ",i))
end
