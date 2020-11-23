include("../phase2/graph.jl")
include("held_karp.jl")

using Test

node1=Node("1", 5)
node2=Node("2", 10)
node3=Node("3", 22)
node4=Node("4", 11)
node5=Node("5", 11)
edge1g=Edge(10.0, (node1,node2))
edge2g=Edge(21.0, (node2,node3))
edge3g=Edge(10.0, (node2,node4))
edge4g=Edge(12.0, (node3,node5))
edge5g=Edge(0.0, (node1,node1))
edge6g=Edge(24.0, (node1,node4))

graph=Graph("graph Test", [node1, node2,node3,node4,node5], [edge1g,edge2g,edge3g,edge4g])
graph2=Graph("graph Test", [node1, node2,node3,node4,node5], [edge1g,edge2g,edge3g,edge4g,edge5g,edge6g])

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

println("subgraph ok")

@test min_weight_edges(graph2,node1)==[edge1g,edge6g] || min_weight_edges(graph2,node1)==[edge6g,edge1g]
@test min_weight_edges(g,nodeB)==[edge1,edge2] || min_weight_edges(g,nodeB)==[edge2,edge1]

println("min_weight_edges ok")

set_node_numbers!(graph)
graph.nodes = [node3,node2,node1,node4,node5]
order_nodes!(graph)

@test graph.nodes == [node1,node2,node3,node4,node5]

println("order_nodes ok")

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
mot = min_one_tree(g,nodeB,true,false)

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

println("min_one_tree ok")

degree_val = degree(g,nodeB)
degrees_ar = degrees(g)

@test degree_val == 3
@test degrees_ar[2] == 3

println("degree et degrees ok")

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
pi = [0,0,0,0,0,0]

w_val, vk, k_otree = w_one_trees(graphw, pi, false, false)

@test w_val == 3

node1x=Node("1", 1)
node2x=Node("2", 1)
node3x=Node("3", 1)
node4x=Node("4", 1)
node5x=Node("5", 1)
node6x=Node("6", 1)

edge1x = Edge(2,(node1x,node2x))
edge2x = Edge(5,(node1x,node3x))
edge3x = Edge(3,(node2x,node4x))
edge4x = Edge(3,(node3x,node4x))
edge5x = Edge(7,(node3x,node5x))
edge6x = Edge(1,(node4x,node5x))
edge7x = Edge(4,(node4x,node6x))
edge8x = Edge(2,(node5x,node6x))

graphx = Graph("Graph x", [node1x,node2x,node3x,node4x,node5x,node6x], [edge1x,edge2x,edge3x,edge4x,edge5x,edge6x,edge7x,edge8x])
pi_x = [2,1,3,1,2,3]

w_valx, vkx, k_otreex = w_one_trees(graphx, pi_x, true, false)

@test w_valx == 12
@test vkx == [-1,0,-1,2,0,0]

println("w_one_trees ok")

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
@test !is_tour(graphx)

println("is_tour ok")

set_node_numbers!(grapht)
edge_nums = get_edge_node_nums(edge5t)
edge_nums2 = get_edge_node_nums(edge8t)
edge_nums3 = get_edge_node_nums(edge9t)

@test edge_nums == (2,5)
@test edge_nums2 == (4,6)
@test edge_nums3 == (5,6)

pi2 = [1,1,1,1,2,1]

set_node_numbers!(graphw)

println("set_node_numbers ok")

old_weights = add_pi_graph!(graphw,pi2)

@test weight(edge4w) == 3
@test weight(edge7w) == 4

sub_pi_graph!(graphw,old_weights)

@test weight(edge3w) == 0
@test weight(edge7w) == 1

println("add_pi_graph et sub_pi_graph ok")

graphtest = create_graph_from_stsp_file("D:/Poly_Montreal/Cours/MTH6412B/projet/phase4/mth6412b-starter-code/instances/stsp/gr17.tsp", false)

pi_mg = zeros(nb_nodes(graphtest))
#for i = 1 : length(pi_mg)
#    pi_mg[i] = rand(0:100)
#end

#graph_res2,max_w_val = max_w(graphtest, 0.1, 10000, pi_mg, false, false)

#println("resultat")
#show(graph_res2)
#println(degrees(graph_res2))

println("Testing complete!")