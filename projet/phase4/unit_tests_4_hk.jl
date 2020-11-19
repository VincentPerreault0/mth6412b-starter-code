include("../phase2/graph.jl")
include("held_karp.jl")

using Test

node1=Node("1", 5)
node2=Node("2", 10)
node3=Node("3", 22)
node4=Node("4", 11)
node5=Node("5", 11)
edge1=Edge(10.0, (node1,node2))
edge2=Edge(21.0, (node2,node3))
edge3=Edge(10.0, (node2,node4))
edge4=Edge(12.0, (node3,node5))
dict_edges=Dict{Node, Vector{Edge}}()
dict_edges[node2]=Vector{Edge}()
dict_edges[node2]=[edge2,edge3]
dict_edges[node3]=[edge4, edge2]
dict_edges[node4]=[edge3]
dict_edges[node5]=[edge4]

graph=Graph("graph Test", [node1, node2,node3,node4,node5], [edge1,edge2,edge3,edge4])

# Exemple vu en cours
nodeA = Node("a", nothing)
nodeB = Node("b", nothing)
nodeC = Node("c", nothing)
nodeD = Node("d", nothing)
nodeE = Node("e", nothing)
nodeF = Node("f", nothing)
nodeG = Node("g", nothing)
nodeH = Node("h", nothing)
nodeI = Node("i", nothing)

edge1 = Edge(4,(nodeA,nodeB))
edge2 = Edge(8,(nodeB,nodeC))
edge3 = Edge(7,(nodeC,nodeD))
edge4 = Edge(9,(nodeD,nodeE))
edge5 = Edge(14,(nodeD,nodeF))
edge6 = Edge(4,(nodeC,nodeF))
edge7 = Edge(2,(nodeC,nodeI))
edge8 = Edge(11,(nodeB,nodeH))
edge9 = Edge(8,(nodeA,nodeH))
edge10 = Edge(7,(nodeH,nodeI))
edge11 = Edge(1,(nodeG,nodeH))
edge12 = Edge(6,(nodeG,nodeI))
edge13 = Edge(2,(nodeF,nodeG))
edge14 = Edge(10,(nodeE,nodeF))

g = Graph("Class Example", [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH, nodeI], [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14])

println("Testing fonctions Held Karp")

sgraph = sub_graph(graph,node3)
sg_edges = edges(sgraph)
for i = 1 : length(sg_edges)
    @test !(node3 in(nodes(sg_edges[i])))
end
@test !(node3 in(nodes(sgraph)))

@test min_weight_edges(g,nodeB)==[edge1,edge2] || min_weight_edges(g,nodeB)==[edge2,edge1]

mot = min_one_tree_two_nodes(g,nodeB,nodeA)

@test nb_nodes(mot) == nb_nodes(g)
@test nb_edges(mot) == 9
@test contains_edge(mot,edge1) == true
@test contains_edge(mot,edge2) == true
@test contains_edge(mot,edge3) == true
@test contains_edge(mot,edge4) == true
@test contains_edge(mot,edge6) == true
@test contains_edge(mot,edge7) == true
@test contains_edge(mot,edge9) == true
@test contains_edge(mot,edge11) == true
@test contains_edge(mot,edge13) == true

reset_graph!(g)
mot = min_one_tree(g,nodeB)

@test nb_nodes(mot) == nb_nodes(g)
@test nb_edges(mot) == 9
@test contains_edge(mot,edge1) == true
@test contains_edge(mot,edge2) == true
@test contains_edge(mot,edge3) == true
@test contains_edge(mot,edge4) == true
@test contains_edge(mot,edge6) == true
@test contains_edge(mot,edge7) == true
@test contains_edge(mot,edge9) == true
@test contains_edge(mot,edge11) == true
@test contains_edge(mot,edge13) == true

degree_val = degree(g,nodeB)
degrees_ar = degrees(g)

@test degree_val == 3
@test degrees_ar[2] == 3

node1w=Node("1", 1)
node2w=Node("2", 1)
node3w=Node("3", 1)
node4w=Node("4", 1)
node5w=Node("5", 1)
node6w=Node("6", 1)

edge1w = Edge(1,(node1w,node2w))
edge2w = Edge(1,(node1w,node3w))
edge3w = Edge(0,(node1w,node6w))
edge4w = Edge(1,(node2w,node3w))
edge5w = Edge(0,(node2w,node5w))
edge6w = Edge(0,(node3w,node4w))
edge7w = Edge(1,(node4w,node5w))
edge8w = Edge(1,(node4w,node6w))
edge9w = Edge(1,(node5w,node6w))

graphw = Graph("Graph w", [node1w,node2w,node3w,node4w,node5w,node6w], [edge1w,edge2w,edge3w,edge4w,edge5w,edge6w,edge7w,edge8w,edge9w])
pi = [1,2,3,1,2,3]

w_val, vk, k_otree = w_one_trees(graphw, pi)

show(k_otree)
@test w_val == 1

node1t=Node("1", 1)
node2t=Node("2", 1)
node3t=Node("3", 1)
node4t=Node("4", 1)
node5t=Node("5", 1)
node6t=Node("6", 1)

edge1t = Edge(1,(node1t,node2t))
edge2t = Edge(1,(node1t,node3t))
edge5t = Edge(0,(node2t,node5t))
edge6t = Edge(0,(node3t,node4t))
edge8t = Edge(1,(node4t,node6t))
edge9t = Edge(1,(node5t,node6t))

grapht = Graph("Graph t", [node1t,node2t,node3t,node4t,node5t,node6t], [edge1t,edge2t,edge5t,edge6t,edge8t,edge9t])

@test is_tour(grapht)

#graphbayg = create_graph_from_stsp_file("D:/Poly_Montreal/Cours/MTH6412B/projet/phase4/mth6412b-starter-code/instances/stsp/bayg29.tsp", true)

#show(graphbayg)

set_node_numbers!(grapht)
edge_nums = get_edge_node_nums(edge5t)
edge_nums2 = get_edge_node_nums(edge8t)
edge_nums3 = get_edge_node_nums(edge9t)

@test edge_nums == (2,5)
@test edge_nums2 == (4,6)
@test edge_nums3 == (5,6)

pi2 = [1,1,1,1,2,1]

set_node_numbers!(graphw)

old_weights = add_pi_graph!(graphw,pi2)

@test weight(edge4w) == 3
@test weight(edge7w) == 4

sub_pi_graph!(graphw,old_weights)

@test weight(edge3w) == 0
@test weight(edge7w) == 1

graph_res = max_w(graphw, 1.2, 1000)

#show(graph_res)
#println(degrees(graph_res))


node1a=Node("1", 1)
node2a=Node("2", 1)
node3a=Node("3", 1)
node4a=Node("4", 1)
node5a=Node("5", 1)
node6a=Node("6", 1)

edge1a = Edge(0,(node1a,node2a))
edge2a = Edge(1,(node1a,node3a))
edge3a = Edge(0,(node1a,node6a))
edge4a = Edge(0,(node2a,node3a))
edge5a = Edge(1,(node2a,node5a))
edge6a = Edge(0,(node3a,node4a))
edge7a = Edge(0,(node4a,node5a))
edge8a = Edge(1,(node4a,node6a))
edge9a = Edge(0,(node5a,node6a))

grapha = Graph("Graph a", [node1a,node2a,node3a,node4a,node5a,node6a], [edge1a,edge2a,edge3a,edge4a,edge5a,edge6a,edge7a,edge8a,edge9a])

#mot2 = min_one_tree(grapha,node2a)

#show(mot2)

#graph_res2 = max_w(graphbayg, 5.0, 50)
#show(graph_res2)
#println(degrees(graph_res2))


println("Testing complete!")