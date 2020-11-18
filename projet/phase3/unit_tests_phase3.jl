using Test
include("../phase2/graph.jl")
include("new_min_span_tree.jl")
include("prim.jl")
include("../phase4/held_karp.jl")


#Tests pour nouvelles fonctions de Node
println("Testing Node methods...")
node1=Node("Joe", 1,5,nothing,6)
node2=Node("James",3)
node3=Node("Matt", 6, 2)
node4=Node("Rebeca",9, node3)

@test name(node1)=="Joe"
@test data(node1)==1
@test rank(node1)==5
@test parent(node1)===nothing
@test minweight(node1)==6

@test data(node2)==3
@test rank(node2)==0
@test parent(node2)===nothing
@test minweight(node2)==10000

@test data(node3)==6
@test rank(node3)==2
@test parent(node2)===nothing
@test minweight(node2)==10000

@test parent(node4)===node3
@test minweight(node4)==10000

node3.parent=node2
node2.parent=node1
@test find_root(node4, nothing)==node1
@test node2.parent==node1
@test node3.parent==node1

#Test pour nouvelles fonctions de Graph 
g=create_empty_graph("BigG", Int)
add_node!(g,node1)
add_node!(g,node1)

@test nb_nodes(g)==1
@test contains_node(g, node1)==true
@test total_weight(g)==0 

edge1=Edge(1000.0, (node1,node2))
add_edge!(g, edge1)

@test nb_nodes(g)==2
@test nb_edges(g)==1
@test total_weight(g)==1000.0

#Test pour New Min Span Tree
println("Testing New Minimum Spanning Tree Kruskal Algorithm with range and depth...")
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

g3 = Graph("Class Example", [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH, nodeI], [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14])
#show(g3)
mst = new_min_span_tree(g3, false)
#show(mst)

@test nb_nodes(mst) == nb_nodes(g3)
@test nb_edges(mst) == 8
@test contains_edge(mst,edge1) == true
@test contains_edge(mst,edge2) == true || contains_edge(mst,edge9) == true  # ces 2 liens ont le même poids dans le graphe et, selon l'ordre utilisé dans sa construction explicite, l'algorithme de Kruskal va finir par en utiliser un et un seul pour son arbre de recouvrement minimal
@test contains_edge(mst,edge3) == true
@test contains_edge(mst,edge4) == true
@test contains_edge(mst,edge6) == true
@test contains_edge(mst,edge7) == true
@test contains_edge(mst,edge11) == true
@test contains_edge(mst,edge13) == true

#Tests pour PriorityQueue
println("Testing PriorityQueue methods...")
node1=Node("Joe", 1,5,nothing,6)
node1.minweight=2
node2=Node("James",3)
node2.minweight=1
node3=Node("Matt", 6, 2)
node4=Node("Rebeca",9, node2)
node4.minweight=1
edge1=Edge(100, (node1,node2))

q=PriorityQueue{Node}()

@test is_empty(q) == true
@test items(q)==[]
@test nb_items(q)==0
@test contains_item(q,node1) == false

add_item!(q, node1)

@test nb_items(q) == 1
@test is_empty(q) == false
@test items(q)==[node1]
@test contains_item(q,node1) == true

add_item!(q,node2)
add_item!(q,node2)

@test nb_items(q)==2
@test minimum_item(q, Node)==node2

tmp=popfirst!(q, Node)

@test tmp==node2
@test nb_items(q)==1
@test contains_item(q,node2) == false
@test contains_item(q,node1) == true

#Test pour PriorityQueue avec Edge comme item 
edge1=Edge(100, (node1,node2))
edge2=Edge(100, (node2,node3))
edge3=Edge(1, (node3, node1))
node3.parent=node2
p=PriorityQueue{Edge}()

@test is_empty(p) == true
@test items(p)==[]
@test nb_items(p)==0
@test contains_item(p,edge1) == false

add_item!(p,edge1)
add_item!(p,edge1)

@test is_empty(p) == false
@test items(p)==[edge1]
@test nb_items(p)==1
@test contains_item(p,edge1) == true

add_item!(p, edge2)

@test popfirst!(p,Edge)==edge1

add_item!(p,edge1)

@test popfirst!(p, node3)==edge2

add_item!(p,edge3)

@test minimum_item(p,Edge)==edge3

#Tests pour algorithme de Prim 
println("Testing Prim's algorithm...")
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

g3 = Graph("Class Example", [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH, nodeI], [edge1, edge2, edge3, edge4, edge5, edge6, edge7, edge8, edge9, edge10, edge11, edge12, edge13, edge14])
#show(g3)
mst_prim = prim(g3, nodeA)
#show(mst_prim)

@test name(mst_prim)=="Minimum Spanning tree from Prim alg of Class Example"
@test nb_nodes(mst_prim) == nb_nodes(g3)
@test nb_edges(mst_prim) == 8
@test contains_edge(mst_prim,edge1) == true
@test contains_edge(mst_prim,edge2) == true || contains_edge(mst_prim,edge9) == true  # ces 2 liens ont le même poids dans le graphe et, selon l'ordre utilisé dans sa construction explicite, l'algorithme de Kruskal va finir par en utiliser un et un seul pour son arbre de recouvrement minimal
@test contains_edge(mst_prim,edge3) == true
@test contains_edge(mst_prim,edge4) == true
@test contains_edge(mst_prim,edge6) == true
@test contains_edge(mst_prim,edge7) == true
@test contains_edge(mst_prim,edge11) == true
@test contains_edge(mst_prim,edge13) == true
show(nodeF)

println("Testing with stsp instances...")
println()
filenames = ["instances/stsp/bayg29.tsp",
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

for i=1:length(filenames)
  graph = create_graph_from_stsp_file(filenames[i], false)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
  mst1 = new_min_span_tree(graph, false)
  println(name(mst1), " has ", nb_nodes(mst1), " nodes and ", nb_edges(mst1), " edges and weight ",total_weight(mst1))
  mst2=prim(graph,nodes(graph)[10])
  println(name(mst2), " has ", nb_nodes(mst2), " nodes and ", nb_edges(mst2), " edges and weight ", total_weight(mst2))
  println()
end

println("All tests complete")
