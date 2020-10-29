### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 5306c162-03f3-11eb-3b80-3577af92365c
md"# Rapport du projet d'Implémentation d'algo. de rech. opérationnelle
## Phase 2 : 05/10/2020
Antonin Kenens, Vincent Perreault et Laura Kolcheva
Dépôt github à l'adresse suivante : [https://github.com/VincentPerreault0/mth6412b-starter-code/tree/phase2](https://github.com/VincentPerreault0/mth6412b-starter-code/tree/phase2)
### Question 1 : Implémenter une structure de données pour les composantes connexes.
Nous avons réutilisé nos structures de données précédentes pour les noeuds et les liens."

# ╔═╡ 38e5bb30-03f6-11eb-332a-7161bc93b80e
begin
	"""Type abstrait dont d'autres types de noeuds dériveront."""
	abstract type AbstractNode{T} end
	
	"""Type représentant les noeuds d'un graphe."""
	mutable struct Node{T} <: AbstractNode{T}
		name::String
		data::T
	end
	
	"""Type représentant les arêtes d'un graphe."""
	struct Edge
	  weight::Float64
	  nodes::Tuple{AbstractNode,AbstractNode}
	end
end

# ╔═╡ 281f7dd0-03f7-11eb-32f9-c51ffbb3cfb4
md"Nous avons ensuite étendu les méthodes de notre implémentation de AbstractGraph pour préparer le terrain aux nécessités des composantes connexes."

# ╔═╡ 4be66d50-03f7-11eb-38d5-afc50ceb8a9e
begin
	"""Type abstrait dont d'autres types de noeuds dériveront."""
	abstract type AbstractGraph{T} end
	
	"""Renvoie le nom du graphe."""
	name(graph::AbstractGraph) = graph.name
	
	"""Renvoie la liste des noeuds du graphe."""
	nodes(graph::AbstractGraph) = graph.nodes
	
	"""Renvoie la liste des arêtes du graphe."""
	edges(graph::AbstractGraph) = graph.edges
	
	"""Renvoie le nombre de noeuds du graphe."""
	nb_nodes(graph::AbstractGraph) = length(graph.nodes)
	
	"""Renvoie le nombre d'arêtes du graphe."""
	nb_edges(graph::AbstractGraph) = length(graph.edges)
	
	"""Vérifie si le graphe contient un certain noeud."""
	contains_node(graph::AbstractGraph{T}, node::Node{T}) where T = node in graph.nodes
	
	"""Ajoute un noeud au graphe."""
	function add_node!(graph::AbstractGraph{T}, node::Node{T}) where T
	  push!(graph.nodes, node)
	  graph
	end
	
	"""Vérifie si le graphe contient un certain lien."""
	contains_edge(graph::AbstractGraph{T}, edge::Edge) where T = edge in graph.edges
	
	"""Ajoute une arête au graphe."""
	function add_edge!(graph::AbstractGraph{T}, edge::Edge) where T
	  push!(graph.edges, edge)
	
	  # Si les noeuds du lien ne font pas partie du graphe, les rajouter
	  for node in edge.nodes
	    if !contains_node(graph, node)
	      add_node!(graph, node)
	    end
	  end
	
	  graph
	end
end

# ╔═╡ f9c477a0-03f7-11eb-0a33-214aae1d470a
md"Nous rappelons ici les méthodes d'affichage pour tous ces types."

# ╔═╡ 0f490af0-03f8-11eb-12d5-e5fd4d401a87
begin
	import Base.show
	
	"""Affiche un noeud."""
	function show(node::AbstractNode)
  		println("Node ", name(node), ", data: ", data(node))
	end
	
	"""Affiche une arête."""
	function show(edge::Edge)
	  println("Edge weight : ", string(weight(edge)))
	  for node in nodes(edge)
	    print("  ")
	    show(node)
	  end
	end
	
	"""Affiche un graphe"""
	function show(graph::AbstractGraph)
	  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", 	nb_edges(graph), " edges.")
	  for node in nodes(graph)
	    show(node)
	  end
	  for edge in edges(graph)
	    show(edge)
	  end
	end
end

# ╔═╡ 577b6750-03f8-11eb-2d86-2332501352c2
md"Nous cachons ci-dessous les méthodes (très longues) pour lire les fichiers stsp."

# ╔═╡ 9c2252fe-03f8-11eb-0d5e-771b7a1409a7
begin
	"""Analyse un fichier .tsp et renvoie un dictionnaire avec les données de l'entête."""
	function read_header(filename::String)
	
	  file = open(filename, "r")
	  header = Dict{String}{String}()
	  sections = ["NAME", "TYPE", "COMMENT", "DIMENSION", "EDGE_WEIGHT_TYPE", "EDGE_WEIGHT_FORMAT",
	  "EDGE_DATA_FORMAT", "NODE_COORD_TYPE", "DISPLAY_DATA_TYPE"]
	
	  # Initialize header
	  for section in sections
	    header[section] = "None"
	  end
	
	  for line in eachline(file)
	    line = strip(line)
	    data = split(line, ":")
	    if length(data) >= 2
	      firstword = strip(data[1])
	      if firstword in sections
	        header[firstword] = strip(data[2])
	      end
	    end
	  end
	  close(file)
	  return header
	end
	
	"""Analyse un fichier .tsp et renvoie un dictionnaire des noeuds sous la forme {id => [x,y]}.
	Si les coordonnées ne sont pas données, un dictionnaire vide est renvoyé.
	Le nombre de noeuds est dans header["DIMENSION"]."""
	function read_nodes(header::Dict{String}{String}, filename::String)
	
	  nodes = Dict{Int}{Vector{Float64}}()
	  node_coord_type = header["NODE_COORD_TYPE"]
	  display_data_type = header["DISPLAY_DATA_TYPE"]
	
	
	  if !(node_coord_type in ["TWOD_COORDS", "THREED_COORDS"]) && !(display_data_type in ["COORDS_DISPLAY", "TWOD_DISPLAY"])
	    return nodes
	  end
	
	  file = open(filename, "r")
	  dim = parse(Int, header["DIMENSION"])
	  k = 0
	  display_data_section = false
	  node_coord_section = false
	  flag = false
	
	  for line in eachline(file)
	    if !flag
	      line = strip(line)
	      if line == "DISPLAY_DATA_SECTION"
	        display_data_section = true
	      elseif line == "NODE_COORD_SECTION"
	        node_coord_section = true
	      end
	
	      if (display_data_section || node_coord_section) && !(line in ["DISPLAY_DATA_SECTION", "NODE_COORD_SECTION"])
	        data = split(line)
	        nodes[parse(Int, data[1])] = map(x -> parse(Float64, x), data[2:end])
	        k = k + 1
	      end
	
	      if k >= dim
	        flag = true
	      end
	    end
	  end
	  close(file)
	  #print(nodes)
	  return nodes
	end
	
	"""Fonction auxiliaire de read_edges, qui détermine le nombre de noeud à lire
	en fonction de la structure du graphe."""
	function n_nodes_to_read(format::String, n::Int, dim::Int)
	  if format == "FULL_MATRIX"
	    return dim
	  elseif format in ["LOWER_DIAG_ROW", "UPPER_DIAG_COL"]
	    return n+1
	  elseif format in ["LOWER_DIAG_COL", "UPPER_DIAG_ROW"]
	    return dim-n
	  elseif format in ["LOWER_ROW", "UPPER_COL"]
	    return n
	  elseif format in ["LOWER_COL", "UPPER_ROW"]
	    return dim-n-1
	  else
	    error("Unknown format - function n_nodes_to_read")
	  end
	end
	
	"""Analyse un fichier .tsp et renvoie l'ensemble des arêtes sous la forme d'un tableau."""
	function read_edges(header::Dict{String}{String}, filename::String)
	
	  edges = []
	  edge_weight_format = header["EDGE_WEIGHT_FORMAT"]
	  known_edge_weight_formats = ["FULL_MATRIX", "UPPER_ROW", "LOWER_ROW",
	  "UPPER_DIAG_ROW", "LOWER_DIAG_ROW", "UPPER_COL", "LOWER_COL",
	  "UPPER_DIAG_COL", "LOWER_DIAG_COL"]
	
	  if !(edge_weight_format in known_edge_weight_formats)
	    @warn "unknown edge weight format" edge_weight_format
	    return edges
	  end
	
	  file = open(filename, "r")
	  dim = parse(Int, header["DIMENSION"])
	  edge_weight_section = false
	  k = 0
	  n_edges = 0
	  i = 0
	  n_to_read = n_nodes_to_read(edge_weight_format, k, dim)
	  flag = false
	
	  for line in eachline(file)
	    line = strip(line)
	    if !flag
	      if occursin(r"^EDGE_WEIGHT_SECTION", line)
	        edge_weight_section = true
	        continue
	      end
	
	      if edge_weight_section
	        data = split(line)
	        n_data = length(data)
	        start = 0
	        while n_data > 0
	          n_on_this_line = min(n_to_read, n_data)
	
	          for j = start : start + n_on_this_line - 1
	            n_edges = n_edges + 1
	            if edge_weight_format in ["UPPER_ROW", "LOWER_COL"]
	              # Modification du format (k+1, i+k+2) en (k+1, (i+k+2, data[j+1]))
	              edge = (k+1, (i+k+2, parse(Float64,data[j+1])))
	            elseif edge_weight_format in ["UPPER_DIAG_ROW", "LOWER_DIAG_COL"]
	              edge = (k+1, (i+k+1, parse(Float64,data[j+1])))
	            elseif edge_weight_format in ["UPPER_COL", "LOWER_ROW"]
	              edge = ((i+k+2, parse(Float64,data[j+1])), k+1)
	            elseif edge_weight_format in ["UPPER_DIAG_COL", "LOWER_DIAG_ROW"]
	              edge = ((i+1, parse(Float64,data[j+1])), k+1)
	            elseif edge_weight_format == "FULL_MATRIX"
	              edge = ((k+1, parse(Float64,data[j+1])), i+1)
	            else
	              warn("Unknown format - function read_edges")
	            end
	            push!(edges, edge)
	            i += 1
	          end
	
	          n_to_read -= n_on_this_line
	          n_data -= n_on_this_line
	
	          if n_to_read <= 0
	            start += n_on_this_line
	            k += 1
	            i = 0
	            n_to_read = n_nodes_to_read(edge_weight_format, k, dim)
	          end
	
	          if k >= dim
	            n_data = 0
	            flag = true
	          end
	        end
	      end
	    end
	  end
	  close(file)
	  return edges
	end
	
	"""Renvoie les noeuds et les arêtes du graphe."""
	function read_stsp(filename::String, verbose::Bool)
	  if verbose
	    Base.print("Reading of header : ")
	  end
	  header = read_header(filename)
	  if verbose
	    println("✓")
	  end
	  dim = parse(Int, header["DIMENSION"])
	  edge_weight_format = header["EDGE_WEIGHT_FORMAT"]
	
	  if verbose
	    Base.print("Reading of nodes : ")
	  end
	  graph_nodes = read_nodes(header, filename)
	  if verbose
	    println("✓")
	  end
	
	  if verbose
	    Base.print("Reading of edges : ")
	  end
	  edges_brut = read_edges(header, filename)
	  graph_edges = []
	  for k = 1 : dim
	    # Modification de edge_list : Int[] -> Tuple{Int, Float}[]
	    edge_list = Tuple{Int, Float64}[]
	    push!(graph_edges, edge_list)
	  end
	
	  for edge in edges_brut
	    if edge_weight_format in ["UPPER_ROW", "LOWER_COL", "UPPER_DIAG_ROW", "LOWER_DIAG_COL"]
	      push!(graph_edges[edge[1]], edge[2])
	    else
	      push!(graph_edges[edge[2]], edge[1])
	    end
	  end
	
	  for k = 1 : dim
	    graph_edges[k] = sort(graph_edges[k])
	  end
	  if verbose
	    println("✓")
	  end
	  return graph_nodes, graph_edges
	end
end

# ╔═╡ b7b88cb2-03f8-11eb-176f-03108712a52d
md"Nous pouvons maintenant donner les méthodes de la structure concrète d'un graphe."

# ╔═╡ d736aef0-03f8-11eb-2464-17aa83541f7b
begin
	"""Structure concrète d'un graphe."""
	mutable struct Graph{T} <: AbstractGraph{T}
	  name::String
	  nodes::Vector{Node{T}}
	  edges::Vector{Edge}
	end
	
	"""Crée un graphe vide."""
	create_empty_graph(graphname::String, type::Type) = Graph{type}(graphname,[],[])
	
	"""Crée un graphe symétrique depuis un ficher lisible par read_stsp."""
	function create_graph_from_stsp_file(filepath::String, verbose::Bool)
	  # Utilisation de la fonction read_stsp
	  graph_nodes, graph_edges = read_stsp(filepath, verbose)
	
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
	
	  # Création du nom du graphe à partir du nom du fichier
	  split_filepath = split(filepath, "/")
	  filename = split_filepath[length(split_filepath)]
	  split_filename = split(filename, ".")
	  graphname = String(split_filename[1])
	
	  # Création du graphe
	  return Graph(graphname, nodes, edges)
	end
end

# ╔═╡ 01be4980-03f9-11eb-1f3d-cd8b8ccb2c6c
md"Nous pouvons finalement donner notre implémentation de la structure de données concrète d'une composante connexe, ainsi que ses méthodes qui seront nécessaires pour l'algorithme."

# ╔═╡ 513c2bd0-03f9-11eb-371c-cd6aaf23a02f
begin
	"""Type representant une composante connexe comme un graphe."""
	mutable struct ConnectedComponent{T} <: AbstractGraph{T}
	  name::String
	  nodes::Vector{Node{T}}
	  edges::Vector{Edge}
	end
	
	"""Crée une composante connexe à partir d'un noeud."""
	create_connected_component_from_node(node::Node{T}) where T = ConnectedComponent{T}("Connected component containing node " * node.name,[node],[])
	
	"""Calcule le nombre de noeuds d'un lien contenus dans la composante connexe."""
	function contains_edge_nodes(c_component::ConnectedComponent{T}, edge::Edge) where T
	  nb_nodes_contained = 0
	  for node in edge.nodes
	    if contains_node(c_component, node)
	      nb_nodes_contained += 1
	    end
	  end
	  return nb_nodes_contained
	end
	
	"""Fusionne deux composantes connexes reliées par un lien."""
	function merge_connected_components!(c_component1::ConnectedComponent{T}, c_component2::ConnectedComponent{T}, linking_edge::Edge) where T
	
	  # Fusion des noeuds
	  for node in c_component2.nodes
	    add_node!(c_component1, node)
	  end
	
	  # Fusion des liens
	  for edge in c_component2.edges
	    add_edge!(c_component1, edge)
	  end
	
	  # Ajout du lien les reliant
	  add_edge!(c_component1, linking_edge)
	
	  return c_component1
	end
end

# ╔═╡ 7deee3c0-03f9-11eb-052c-b15a37f9b70d
md"### Question 2 : Implémenter l'algorithme de Kruskal pour un arbre de recouvrement minimal.
Avec les méthodes que nous avons défini dans la dernière question pour les composantes connexes, il nous est aisé d'implémenter l'algorithme de Kruskal."

# ╔═╡ d95f8cf0-03f9-11eb-1a4c-752a8c97692c
"""Algorithme de Kruskal pour calculer un arbre de recouvrement minimal d'un graphe symétrique connexe."""
function find_minimum_spanning_tree(graph::AbstractGraph{T}, verbose::Bool) where T

  # Création une composante connexe pour chaque noeud du graphe
  connected_components = Vector{ConnectedComponent{T}}()
  for node in nodes(graph)
    push!(connected_components, create_connected_component_from_node(node))
  end

  # Ordonnement des liens par poids croissants
  graph_edges = edges(graph)
  sort!(graph_edges, by=e -> e.weight)

  # Pour chaque lien,
  for edge in graph_edges
    if verbose
      print("Searching ")
      show(edge)
    end
		
    # Trouver la ou les composantes connexes y touchant.
    linked_ccs = Vector{ConnectedComponent{T}}()
    for cc in connected_components
      nb_nodes_contained = contains_edge_nodes(cc, edge)
			
      # Si le lien touche à une seule composante, passer au lien suivant.
      if nb_nodes_contained == 2
        if verbose
          println("Found in " * cc.name * ".")
        end
        break
      elseif nb_nodes_contained == 1
        push!(linked_ccs, cc)
        if length(linked_ccs) == 2
          break
        end
      end
    end
		
    # Si le lien touche à 2 composantes connexes distinctes, les fusionner
    if length(linked_ccs) == 2
      if verbose
        println("Found between " * linked_ccs[1].name * " and " * linked_ccs[2].name * ". => Merging components.")
      end
  
      sort!(linked_ccs, by=cc -> nb_nodes(cc), rev = true)
      merge_connected_components!(linked_ccs[1], linked_ccs[2], edge)
      deleteat!(connected_components, findall(cc->cc==linked_ccs[2], connected_components))

      # Si nous n'obtenons plus qu'une seule composante connexe, éviter les boucles inutiles
      if length(connected_components) == 1
        break
      end
    end
  end

  # Si le graphe initial n'était pas connexe, choisir la plus grosse composante connexe finale
  if length(connected_components) > 1
    sort!(connected_components, by=cc -> nb_nodes(cc), rev = true)
  end

  return Graph("Minimal spanning tree of " * name(graph), nodes(connected_components[1]), edges(connected_components[1]))
end

# ╔═╡ d6632060-03fa-11eb-22ed-6d4638537d55
begin
	using Test
	
	# Tests pour les méthodes de Graph
	println("Testing Graph methods...")
	println()
	
	node1 = Node("Joe", 3.14)
	node2 = Node("Steve", exp(1))
	node3 = Node("Jill", 4.12)
	edge1 = Edge(500, (node1, node2))
	edge2 = Edge(1000, (node2, node3))
	
	g1 = create_empty_graph("g1",Float64)
	
	@test name(g1) == "g1"
	@test nb_nodes(g1) == 0
	@test nb_edges(g1) == 0
	@test contains_node(g1,node1) == false
	@test contains_edge(g1,edge1) == false
	
	add_node!(g1,node1)
	
	@test nb_nodes(g1) == 1
	@test contains_node(g1,node1) == true
	
	add_edge!(g1,edge1)
	
	@test nb_edges(g1) == 1
	@test contains_edge(g1,edge1) == true
	@test nb_nodes(g1) == 2
	@test contains_node(g1,node2) == true
	
	add_node!(g1,node3)
	add_edge!(g1,edge2)
	
	#show(g1)
	#println()
	
	@test nb_nodes(g1) == 3
	@test contains_node(g1,node3) == true
	@test nb_edges(g1) == 2
	@test contains_edge(g1,edge2) == true
	
	g2 = Graph("g2", [node1, node2, node3], [edge1, edge2])
	
	#show(g2)
	#println()
	
	@test name(g1) != name(g2)
	@test nodes(g1) == nodes(g2)
	@test edges(g1) == edges(g2)
	
	
	# Tests pour les méthodes de Connected Component
	println("Testing ConnectedComponent methods...")
	println()
	
	cc1 = create_connected_component_from_node(node1)
	
	@test name(cc1) == "Connected component containing node Joe"
	@test nb_nodes(cc1) == 1
	@test contains_node(cc1,node1) == true
	@test nb_edges(cc1) == 0
	
	@test contains_edge_nodes(cc1, edge2) == 0
	@test contains_edge_nodes(cc1, edge1) == 1
	
	cc2 = create_connected_component_from_node(node2)
	
	@test contains_edge_nodes(cc2, edge1) == 1
	@test contains_edge_nodes(cc2, edge2) == 1
	
	merge_connected_components!(cc1,cc2,edge1)
	
	@test nb_nodes(cc1) == 2
	@test contains_node(cc1,node1) == true
	@test contains_node(cc1,node2) == true
	@test nb_edges(cc1) == 1
	@test contains_edge(cc1,edge1) == true
	
	@test contains_edge_nodes(cc1, edge1) == 2
	@test contains_edge_nodes(cc1, edge2) == 1
	
	cc3 = create_connected_component_from_node(node3)
	merge_connected_components!(cc1,cc3,edge2)
	
	#show(cc1)
	#println()
	
	@test name(g1) != name(cc1)
	@test nodes(g1) == nodes(cc1)
	@test edges(g1) == edges(cc1)
	
	
	# Tests pour l'algorithme de Kruskal pour un arbre de recouvrement minimal
	println("Testing Minimum Spanning Tree Kruskal Algorithm...")
	println()
	
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
	#println()
	
	mst = find_minimum_spanning_tree(g3, true)
	println()
	
	#show(mst)
	#println()
	
	@test nb_nodes(mst) == nb_nodes(g3)
	@test nb_edges(mst) == 8
	@test contains_edge(mst,edge1) == true
	@test contains_edge(mst,edge2) == true || contains_edge(mst,edge9) == true # ces 2 liens ont le même poids dans le graphe et, selon l'ordre utilisé dans sa construction explicite, l'algorithme de Kruskal va finir par en utiliser un et un seul pour son arbre de recouvrement minimal
	@test contains_edge(mst,edge3) == true
	@test contains_edge(mst,edge4) == true
	@test contains_edge(mst,edge6) == true
	@test contains_edge(mst,edge7) == true
	@test contains_edge(mst,edge11) == true
	@test contains_edge(mst,edge13) == true
	
	println("All tests complete!")
end

# ╔═╡ 75a691d0-03fa-11eb-2a4b-edb7f8fb12f9
md"Le test sur l'exemple vu en cours sera fait dans la prochaine section.
### Question 3 : Tests unitaires.
Pour tester les méthodes de AbstractGraph, celles de ConnectedComponent ainsi que l'algorithme de Kruskal, nous avons implémenter la série de tests unitaires ci-dessous."

# ╔═╡ cfe77820-03fb-11eb-0b68-c9f065d0e1d7
md"*Note : Nous n'arrivons pas à faire fonctionner la macro '@test' dans le carnet Pluto, mais tout fonctionne sans problème dans VS Code.*"

# ╔═╡ 27500690-03fc-11eb-0cb2-cd1ab75ba683
md"Avec cete série de tests, nous obtenons la sortie suivante."

# ╔═╡ 3efa6010-03fc-11eb-20e2-eb341c73854f
md"	Testing Graph methods...

	Testing ConnectedComponent methods...

	Testing Minimum Spanning Tree Kruskal Algorithm...

	Searching Edge weight : 1.0
	  Node g, data: nothing
	  Node h, data: nothing
	Found between Connected component containing node g and Connected component containing node h. => Merging components.
	Searching Edge weight : 2.0
	  Node c, data: nothing
	  Node i, data: nothing
	Found between Connected component containing node c and Connected component containing node i. => Merging components.
	Searching Edge weight : 2.0
	  Node f, data: nothing
	  Node g, data: nothing
	Found between Connected component containing node f and Connected component containing node g. => Merging components.
	Searching Edge weight : 4.0
	  Node a, data: nothing
	  Node b, data: nothing
	Found between Connected component containing node a and Connected component containing node b. => Merging components.
	Searching Edge weight : 4.0
	  Node c, data: nothing
	  Node f, data: nothing
	Found between Connected component containing node c and Connected component containing node g. => Merging components.
	Searching Edge weight : 6.0
	  Node g, data: nothing
	  Node i, data: nothing
	Found in Connected component containing node g.
	Searching Edge weight : 7.0
	  Node c, data: nothing
	  Node d, data: nothing
	Found between Connected component containing node d and Connected component containing node g. => Merging components.
	Searching Edge weight : 7.0
	  Node h, data: nothing
	  Node i, data: nothing
	Found in Connected component containing node g.
	Searching Edge weight : 8.0
	  Node b, data: nothing
	  Node c, data: nothing
	Found between Connected component containing node a and Connected component containing node g. => Merging components.
	Searching Edge weight : 8.0
	  Node a, data: nothing
	  Node h, data: nothing
	Found in Connected component containing node g.
	Searching Edge weight : 9.0
	  Node d, data: nothing
	  Node e, data: nothing
	Found between Connected component containing node e and Connected component containing node g. => Merging components.

	All tests complete!"

# ╔═╡ 370f2242-03fd-11eb-229c-1f33aeb52ed0
md"Si nous examinons la sortie de l'algorithme, nous reconnaissons l'algorithme de Kruskal tel qu'utilisé dans le cours. La seule exception est le lien \[b,c\] qui est utilisé au lieu du lien \[a,h\] puisqu'il est vu en premier par l'algorithme. Ces deux liens ayant le même poids, nous retrouvons bien un arbre de recouvrement minimal équivalent."

# ╔═╡ 13e4cb70-03fe-11eb-2628-35362a6fe3f1
md"### Question 4 : Tests sur instances de TSP symétriques.
Nous avons testé notre implémentation sur toutes les instances de TSP symétriques fournies avec le code suivant."

# ╔═╡ ec1c0d50-03fe-11eb-21d9-5b465d93cc57
md"*Note : Le filepath a dû être ajouté sur le carnet Pluto pour faire fonctionner le code.*"

# ╔═╡ c0c82210-03fe-11eb-1103-7bad195dba6c
begin
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
	
	filepath = "C:/Users/Vincent/Dropbox/2020- Maîtrise/Session 1/Impl d'Algo de Rech Oper/Projet/mth6412b-starter-code/"
	
	for filename in filenames
	  graph = create_graph_from_stsp_file(filepath * filename, false)
	  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
	
	  mst = find_minimum_spanning_tree(graph, false)
	  println("Graph ", name(mst), " has ", nb_nodes(mst), " nodes and ", nb_edges(mst), " edges.")
	
	  println()
	end
end

# ╔═╡ 2472f6f0-03ff-11eb-2495-55fdd9241e1d
md"Avec ce code, nous obtenons la sortie suivante."

# ╔═╡ 336baad0-03ff-11eb-03f6-c9b40f46de01
md"	Graph bayg29 has 29 nodes and 406 edges.
	Graph Minimal spanning tree of bayg29 has 29 nodes and 28 edges.
	
	Graph bays29 has 29 nodes and 841 edges.
	Graph Minimal spanning tree of bays29 has 29 nodes and 28 edges.
	
	Graph brazil58 has 58 nodes and 1653 edges.
	Graph Minimal spanning tree of brazil58 has 58 nodes and 57 edges.
	
	Graph brg180 has 180 nodes and 16110 edges.
	Graph Minimal spanning tree of brg180 has 180 nodes and 179 edges.
	
	Graph dantzig42 has 42 nodes and 903 edges.
	Graph Minimal spanning tree of dantzig42 has 42 nodes and 41 edges.
	
	Graph fri26 has 26 nodes and 351 edges.
	Graph Minimal spanning tree of fri26 has 26 nodes and 25 edges.
	
	Graph gr17 has 17 nodes and 153 edges.
	Graph Minimal spanning tree of gr17 has 17 nodes and 16 edges.
	
	Graph gr21 has 21 nodes and 231 edges.
	Graph Minimal spanning tree of gr21 has 21 nodes and 20 edges.
	
	Graph gr24 has 24 nodes and 300 edges.
	Graph Minimal spanning tree of gr24 has 24 nodes and 23 edges.
	
	Graph gr48 has 48 nodes and 1176 edges.
	Graph Minimal spanning tree of gr48 has 48 nodes and 47 edges.
	
	Graph gr120 has 120 nodes and 7260 edges.
	Graph Minimal spanning tree of gr120 has 120 nodes and 119 edges.
	
	Graph hk48 has 48 nodes and 1176 edges.
	Graph Minimal spanning tree of hk48 has 48 nodes and 47 edges.
	
	Graph pa561 has 561 nodes and 157641 edges.
	Graph Minimal spanning tree of pa561 has 561 nodes and 560 edges.
	
	Graph swiss42 has 42 nodes and 1764 edges.
	Graph Minimal spanning tree of swiss42 has 42 nodes and 41 edges."

# ╔═╡ 6fb52b60-03ff-11eb-18f5-197003df938a
md"Comme on peut le lire, nous obtenons la sortie attendue, c'est-à-dire que nous obenons pour chaque graphe d'entrée un graphe connexe en sortie avec le même nombre de noeud *N* et un nombre de lien égal à *N*-1. Les graphe de sortie étant connexes par construction, nous obtenons ainsi bien des arbres de recouvrement. De plus, l'algorithme de Kruskal assure que ces arbres de recouvrement sont bel et bien minimaux."

# ╔═╡ Cell order:
# ╠═5306c162-03f3-11eb-3b80-3577af92365c
# ╠═38e5bb30-03f6-11eb-332a-7161bc93b80e
# ╟─281f7dd0-03f7-11eb-32f9-c51ffbb3cfb4
# ╠═4be66d50-03f7-11eb-38d5-afc50ceb8a9e
# ╟─f9c477a0-03f7-11eb-0a33-214aae1d470a
# ╠═0f490af0-03f8-11eb-12d5-e5fd4d401a87
# ╟─577b6750-03f8-11eb-2d86-2332501352c2
# ╟─9c2252fe-03f8-11eb-0d5e-771b7a1409a7
# ╟─b7b88cb2-03f8-11eb-176f-03108712a52d
# ╠═d736aef0-03f8-11eb-2464-17aa83541f7b
# ╟─01be4980-03f9-11eb-1f3d-cd8b8ccb2c6c
# ╠═513c2bd0-03f9-11eb-371c-cd6aaf23a02f
# ╟─7deee3c0-03f9-11eb-052c-b15a37f9b70d
# ╠═d95f8cf0-03f9-11eb-1a4c-752a8c97692c
# ╟─75a691d0-03fa-11eb-2a4b-edb7f8fb12f9
# ╟─cfe77820-03fb-11eb-0b68-c9f065d0e1d7
# ╠═d6632060-03fa-11eb-22ed-6d4638537d55
# ╟─27500690-03fc-11eb-0cb2-cd1ab75ba683
# ╟─3efa6010-03fc-11eb-20e2-eb341c73854f
# ╟─370f2242-03fd-11eb-229c-1f33aeb52ed0
# ╟─13e4cb70-03fe-11eb-2628-35362a6fe3f1
# ╟─ec1c0d50-03fe-11eb-21d9-5b465d93cc57
# ╠═c0c82210-03fe-11eb-1103-7bad195dba6c
# ╟─2472f6f0-03ff-11eb-2495-55fdd9241e1d
# ╟─336baad0-03ff-11eb-03f6-c9b40f46de01
# ╟─6fb52b60-03ff-11eb-18f5-197003df938a
