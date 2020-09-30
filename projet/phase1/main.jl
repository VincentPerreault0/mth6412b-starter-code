
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

project_file_path = "C:/Users/Vincent/Dropbox/2020- Maîtrise/Session 1/Impl d'Algo de Rech Oper/Projet/mth6412b-starter-code/"

#main(project_file_path * "instances/stsp/bayg29.tsp")
#main(project_file_path * "instances/stsp/fri26.tsp")
#main(project_file_path * "instances/stsp/gr120.tsp")
#main(project_file_path * "instances/stsp/bays29.tsp")
#main(project_file_path * "instances/stsp/swiss42.tsp")

file_names = ["instances/stsp/bayg29.tsp",
            "instances/stsp/bays29.tsp",
            "instances/stsp/brazil58.tsp",
            "instances/stsp/brg180.tsp",
            "instances/stsp/dantzig42.tsp",
            "instances/stsp/fri26.tsp",
            "instances/stsp/gr17.tsp",
            "instances/stsp/gr21.tsp",
            "instances/stsp/gr24.tsp",
            "instances/stsp/gr48.tsp",
            "instances/stsp/gr120.tsp",
            "instances/stsp/hk48.tsp",
            "instances/stsp/pa561.tsp",
            "instances/stsp/swiss42.tsp"]

for i = 1 : 14
    main(file_names[i])
    println(string("ok file number : ",i))
end
