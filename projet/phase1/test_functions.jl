
include("graph.jl")
include("node.jl")
include("edge.jl")
include("read_stsp.jl")

"""Fichier de test des fonctions read_stsp, plot_graph et des fichiers
    node.jl, edge.jl et graph.jl"""
function main(filename)
    #read_stsp(filename)
    #plot_graph(filename)
    print("test")
    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    edge1 = Edge(500, (node1, node2))
    edge2 = Edge(1000, (node2, node3))
    G = Graph("Ick", [node1, node2, node3], [edge1, edge2])
    show(G)
end

project_file_path = "C:/Users/Vincent/Dropbox/2020- Maîtrise/Session 1/Impl d'Algo de Rech Oper/Projet/mth6412b-starter-code/"

main(project_file_path * "instances/stsp/bayg29.tsp")
#main(project_file_path * "instances/stsp/fri26.tsp")
#main(project_file_path * "instances/stsp/gr120.tsp")
#main(project_file_path * "instances/stsp/bays29.tsp")
#main(project_file_path * "instances/stsp/swiss42.tsp")