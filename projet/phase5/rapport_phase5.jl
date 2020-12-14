### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ a21c5790-3d70-11eb-2004-d970d56eb8b4
begin
	"""Type abstrait dont d'autres types de noeuds dériveront."""
	abstract type AbstractNode{T} end

	"""Type représentant les noeuds d'un graphe.

	Exemple:

			noeud = Node("James", [π, exp(1)])
			noeud = Node("Kirk", "guitar")
			noeud = Node("Lars", 2)

	"""
	mutable struct Node{T} <: AbstractNode{T}
	  name::String
	  data::T
	  rank::Int64
	  parent ::Union{Nothing,Node{T}}
	  minweight::Float64
	  number::Int64
	end

	"""initialise un noeud uniquement avec un nom et un data""" 
	function Node(name:: String, data)
	  return(Node{typeof(data)}(name, data, 0, nothing, 10000, 0))
	end

	function Node(name:: String, data, rank :: Int64)
	 return(Node{typeof(data)}(name, data, rank, nothing, 10000, 0))
	end

	function Node(name:: String, data, parent :: Node)
	 return(Node{typeof(data)}(name, data, 0, parent, 10000, 0))
	end

	"""Renvoie le nom du noeud."""
	name(node::AbstractNode) = node.name

	"""Renvoie les données contenues dans le noeud."""
	data(node::AbstractNode) = node.data

	"""Renvoie le rank du noeud."""
	rank(node::AbstractNode) = node.rank

	"""Renvoie le parent du noeud."""
	parent(node::AbstractNode) = node.parent

	""" Renvoie minweight du noeud"""
	function minweight(node::AbstractNode)
		node.minweight
	end

	""" Trouve la racine d une composante connexe a partir d'un noeud
	Actualise la racine de tous les noeuds sur le chemin """ 
	function find_root(node :: Node{T}, nodes=nothing) where T
	  if nodes===nothing
		nodes=Node{typeof(node.data)}[]
	  end
	  if parent(node)===nothing #ce noeud est une racine
		for nodetmp in nodes
		  nodetmp.parent=node
		end
		node.parent=nothing #this node was in the array
		return(node)
	  else
		push!(nodes, parent(node))
		find_root(parent(node), nodes)
	  end 
	end 

	"""fonction qui prend en entre les racines de deux composantes connexes et les unis"""
	function union_roots(root1::Node{T}, root2::Node{T}) where T
	  if root1==root2
		return
	  else
		if rank(root1)<rank(root2)
		  root1.parent=root2
		elseif rank(root2)<rank(root1) 
			root2.parent=root1
		else
			root2.parent=root1
			root1.rank+=1
		end
	  end 
	  return
	end 

	"""Remet à 0 les valeurs du noeud autre que name et data"""
	function reset_node!(node::AbstractNode)
	  node.rank = 0
	  node.parent = nothing
	  node.minweight = 100000
	end

	"""Donne un numéro à un node"""
	function set_node_num!(node::AbstractNode, num::Int64)
	  node.number = num
	end

	"""Récupère le numéro d'un node"""
	function get_node_num(node::AbstractNode)
	  return node.number
	end

	"""Type représentant les arêtes d'un graphe.

	Exemple:

			noeud1 = Node("Kirk", "guitar")
			noeud2 = Node("Lars", 2)
			arete = Edge(50, noeud1, noeud2)

	"""
	mutable struct Edge
	  weight::Float64
	  nodes::Tuple{AbstractNode,AbstractNode}
	end

	"""Renvoie le poids de l'arête."""
	function weight(edge::Edge)
		edge.weight
	end

	"""Renvoie les noeuds aux extrémités de l'edge."""
	function nodes(edge::Edge)
		edge.nodes
	end

	"""get the node numbers of an edge"""
	function get_edge_node_nums(edge::Edge)
	  e_nodes = nodes(edge)
	  node_num_1 = get_node_num(e_nodes[1])
	  node_num_2 = get_node_num(e_nodes[2])
	  return (node_num_1, node_num_2)
	end

	"""set new weight of an edge"""
	function set_weight!(edge::Edge, new_weight::Float64)
	  edge.weight = new_weight
	end

	using Plots

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

	"""Affiche un graphe étant données un ensemble de noeuds et d'arêtes.

	Exemple :

		graph_nodes, graph_edges = read_stsp("bayg29.tsp")
		plot_graph(graph_nodes, graph_edges)
		savefig("bayg29.pdf")
	"""
	function plot_graph(nodes, edges)
	  fig = plot(legend=false)

	  # edge positions
	  for k = 1 : length(edges)
		for j in edges[k]
		  plot!([nodes[k][1], nodes[j][1]], [nodes[k][2], nodes[j][2]],
			  linewidth=1.5, alpha=0.75, color=:lightgray)
		end
	  end

	  # node positions
	  xys = values(nodes)
	  x = [xy[1] for xy in xys]
	  y = [xy[2] for xy in xys]
	  scatter!(x, y)

	  fig
	  #savefig("test.png")
	end

	"""Fonction de commodité qui lit un fichier stsp et trace le graphe."""
	function plot_graph(filename::String)
	  graph_nodes, graph_edges = read_stsp(filename, false)
	  plot_graph(graph_nodes, graph_edges)
	end
	
	"""Type abstrait dont d'autres types de noeuds dériveront."""
	abstract type AbstractGraph{T} end

	"""Type abstrait représentant un graphe comme un nom et un ensemble de noeuds et de liens.

	Présume les champs suivants:
	  name::String
	  nodes::Vector{Node{T}}
	  edges::Vector{Edge}

	Attention, tous les noeuds doivent avoir des données de même type.
	"""

	"""Renvoie le nom du graphe."""
	name(graph::AbstractGraph) = graph.name

	"""Renvoie la liste des noeuds du graphe."""
	nodes(graph::AbstractGraph) = graph.nodes

	"""Renvoie la liste des arêtes du graphe."""
	edges(graph::AbstractGraph) = graph.edges

	"""Renvoie le nombre de noeuds du graphe."""
	function nb_nodes(graph::AbstractGraph)
		length(graph.nodes)
	end

	"""Renvoie le nombre d'arêtes du graphe."""
	nb_edges(graph::AbstractGraph) = length(graph.edges)

	"""Vérifie si le graphe contient un certain noeud."""
	function contains_node(graph::AbstractGraph{T}, node::AbstractNode{T}) where T
		node in graph.nodes
	end

	"""Ajoute un noeud au graphe."""
	function add_node!(graph:: AbstractGraph{T}, node::AbstractNode{T}) where T
	  if contains_node(graph,node)
		return(graph)
	  else
		push!(graph.nodes, node)
		return(graph)
	  end
	end

	"""Ajoute un noeud au graphe à la position donnée."""
	function insert_node!(graph:: AbstractGraph{T}, index::Int64, node::AbstractNode{T}) where T
	  if contains_node(graph,node)
		return(graph)
	  else
		insert!(graph.nodes, index, node)
		return(graph)
	  end
	end

	"""Vérifie si le graphe contient un certain lien."""
	contains_edge(graph::AbstractGraph{T}, edge::Edge) where T = edge in graph.edges

	"""Ajoute une arête au graphe."""
	function add_edge!(graph::AbstractGraph{T}, edge::Edge) where T
	  if contains_edge(graph, edge)
		return(graph)
	  else
		push!(graph.edges, edge)
		# Si les noeuds du lien ne font pas partie du graphe, les rajouter
		for node in edge.nodes
		  if !contains_node(graph, node)
			add_node!(graph, node)
		  end
		end
		return(graph)
	  end
	end

	""" donne la somme des poids des arretes d un graphe"""
	function total_weight(graph:: AbstractGraph)
	  if nb_nodes(graph)==0
		return(0)
	  else
		s=0
		for edge in graph.edges
		  s+=weight(edge)
		end
		return(s)
	  end
	end 

	"""Structure concrète d'un graphe."""
	mutable struct Graph{T} <: AbstractGraph{T}
	  name::String
	  nodes::Vector{Node{T}}
	  edges::Vector{Edge}
	end

	"""Structure concrète representant un graphe comme un ensemble de noeuds et de liens.

	Exemple :

		node1 = Node("Joe", 3.14)
		node2 = Node("Steve", exp(1))
		node3 = Node("Jill", 4.12)
		edge1 = Edge(500, (node1, node2))
		edge2 = Edge(1000, (node2, node3))
		G = Graph("Ick", [node1, node2, node3], [edge1, edge2])

	Attention, tous les noeuds doivent avoir des données de même type.
	"""

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

	"""reset graph values to default to avoid side effects"""
	function reset_graph!(graph :: AbstractGraph)
	  g_nodes = nodes(graph)
	  for i = 1 : length(g_nodes)
		reset_node!(g_nodes[i])
	  end
	end

	"""give array value corresponding to the degree of each vertices"""
	function degrees(graph :: AbstractGraph)
	  g_nodes = nodes(graph)
	  g_edges = edges(graph)
	  degrees_ar =  zeros(length(g_nodes))
	  for i = 1 : length(g_nodes)
		for j = 1 : length(g_edges)
		  if g_nodes[i] in nodes(g_edges[j])
			degrees_ar[i] = degrees_ar[i] + 1
		  end
		end
	  end
	  return degrees_ar
	end

	"""give degree for given vertex in graph"""
	function degree(graph :: AbstractGraph, vertex :: AbstractNode)
	  g_edges = edges(graph)
	  degree_val = 0
	  for j = 1 : length(g_edges)
		if vertex in nodes(g_edges[j])
		  degree_val = degree_val + 1
		end
	  end
	  return degree_val
	end

	"""Set the node numbers in a graph"""
	function set_node_numbers!(graph :: AbstractGraph)
	  # L'idée est d'attribuer un numéro à chaque node plutôt que de 
	  # se référer au nom pour rendre l'algorithme plus générique 
	  # au cas où 2 nodes aient des noms identiques
	  g_nodes = nodes(graph)
	  for i = 1 : nb_nodes(graph)
		set_node_num!(g_nodes[i],i)
	  end
	end
	"""Order the nodes in a graph"""
	function order_nodes!(graph :: AbstractGraph)
	  # Cette fonction sert à réorganiser les sommets
	  # pour que le vecteur pi soit bien additionné aux bons
	  # sommets
	  len_nodes = nb_nodes(graph)
	  g_nodes = nodes(graph)
	  ordered_nodes = Vector{typeof(g_nodes[1])}(undef,len_nodes)
	  for i = 1 : len_nodes
		node_num = get_node_num(g_nodes[i])
		ordered_nodes[node_num] = g_nodes[i]
	  end
	  graph.nodes = ordered_nodes
	end
	""" type abstrait de file de priorite"""
	abstract type AbstractQueue{T} end
	"""File de priorité (utilise pour les noeuds ou les edges)"""
	mutable struct PriorityQueue{T} <: AbstractQueue{T}
		items::Vector{T}
	end
	""" Cree une file de priorite vide"""
	function PriorityQueue{T}() where T
		PriorityQueue(T[])
	end
	"""Indique si la file est vide."""
	function is_empty(q::AbstractQueue)
		length(q.items) == 0
	end
	""" Renvoie les elements de la file"""
	function items(q::AbstractQueue)
		q.items
	end
	"""Donne le nombre d'éléments sur la file."""
	function nb_items(q::AbstractQueue)
		return(length(q.items))
	end
	"""renvoie true si la file contien l objet"""
	function contains_item(q::PriorityQueue{T}, item::T) where T
		return(item in q.items)
	end
	"""Ajoute `item` à la fin de la file."""
	function add_item!(q::AbstractQueue{T}, item::T) where T
		if contains_item(q,item)
			return(q)
		end
		push!(q.items, item)
		return(q)
	end
	"""renvoie le plus petit element de la file"""
	function minimum_item(q::AbstractQueue, type ::Type )
		min=items(q)[1]
		if type==Node
			for node in q.items[2:end]
				if minweight(node)<minweight(min)
					min=node
				end
			end
		elseif type==Edge
			for edge in q.items[2:end]
				if weight(edge)<weight(min)
					min=edge
				end
			end
		end
		return(min)
	end
	"""Retire et renvoie un élément ayant la plus haute priorité.
	Ici la priorite est l ordre decroissant. """
	function popfirst!(q::PriorityQueue, type::Type)
		highest = minimum_item(q,type)
		idx = findall(x -> x == highest, q.items)[1]
		deleteat!(q.items, idx)
		return(highest)
	end
	"""Retire et renvoie l'élément ayant la plus haute priorité
	 et qui contient le noeud choisit et son parent.
	 Si il y a plusieurs edge de meme poids, on choisit celui correspondant
	 au noeud choisit.Si aucum edge de poids minimal ne correspond au noeud,
	on supprime les edge de poids minimal et on reitere"""
	function popfirst!(q:: PriorityQueue{Edge}, node:: Node)
		min= minimum_item(q,Edge)
		idx = findall(x -> weight(x) == weight(min), q.items)
		tmp=-1
		for i in idx
			if node in nodes(items(q)[i]) && parent(node) in nodes(items(q)[i])
				tmp=i
				break
			end
		end
		if tmp==-1# si on est la c'est que les edge de poids min ne vont jamais etre utilise
			compteur=0
			for i in idx
				deleteat!(q.items, i-compteur)
				compteur=compteur+1
			end
			return(popfirst!(q, node))#on refait sur la file updatee 
		else
			edge=items(q)[tmp]
			deleteat!(q.items, tmp)
			return(edge)
		end
	end
end

# ╔═╡ 8e12f4c0-3d7f-11eb-2894-13e7ed1985f1
begin
	using Random, FileIO, Images, ImageView, ImageMagick

	"""Compute the similarity score between two pixels."""
	function compare_pixels(p1, p2)
		r1, g1, b1 = Float64(red(p1)), Float64(green(p1)), Float64(blue(p1))
		r2, g2, b2 = Float64(red(p2)), Float64(green(p2)), Float64(blue(p2))
		return abs(r1-r2) + abs(g1-g2) + abs(b1-b2)
	end

	"""Compute the similarity score between two columns of pixels in an image."""
	function compare_columns(col1, col2)
		score = 0
		nb_row = length(col1)
		for row = 1 : nb_row - 1
			score += compare_pixels(col1[row], col2[row])
		end
		return score
	end

	"""Compute the overall similarity score of a PNG image."""
	function score_picture(filename::String)
		picture = load(filename)
		nb_col = size(picture, 2)
		score = 0
		for col = 1 : nb_col - 1
			score += compare_columns(picture[:,col], picture[:,col+1])
		end
		return score
	end

	"""Write a tour in TSPLIB format."""
	function write_tour(filename::String, tour::Array{Int}, cost::Float64)
		file = open(filename, "w")
		length_tour = length(tour)
		write(file,"NAME : $filename\n")
		write(file,"COMMENT : LENGHT = $cost\n")
		write(file,"TYPE : TOUR\n")
		write(file,"DIMENSION : $length_tour\n")
		write(file,"TOUR_SECTION\n")
		for node in tour
			write(file, "$(node)\n")
		end
		write(file, "-1\nEOF\n")
		close(file)
	end

	"""Shuffle the columns of an image randomly or using a given permutation."""
	function shuffle_picture(input_name::String, output_name::String; view::Bool=false, permutation=[])
		picture = load(input_name)
		nb_row, nb_col = size(picture)
		shuffled_picture = similar(picture)
		if permutation == []
			permutation = shuffle(1:nb_col)
		end
		for col = 1 : nb_col
			shuffled_picture[:,col] = picture[:,permutation[col]]
		end
		view && imshow(shuffled_picture)
		save(output_name, shuffled_picture)
	end

	"""Read a tour file and a shuffled image, and output the image reconstructed using the tour."""
	function reconstruct_picture(tour_filename::String, input_name::String, output_name::String; view::Bool=false)
		tour = Int[]
		file = open(tour_filename, "r")
		in_tour_section = false
		for line in eachline(file)
			line = strip(line)
			if line == "TOUR_SECTION"
				in_tour_section = true
			elseif in_tour_section
				node = parse(Int, line)
				if node == -1
					break
				else
					push!(tour, node - 1)
				end
			end
		end
		close(file)
		shuffled_picture = load(input_name)
		reconstructed_picture = shuffled_picture[:,tour[2:end]]
		view && imshow(reconstructed_picture)
		save(output_name, reconstructed_picture)
	end
end

# ╔═╡ 41345f50-3d88-11eb-27c3-cd012a33c590
begin 
	using Pkg
	Pkg.add("TestImages")
	Pkg.add("GtkReactive")
end 

# ╔═╡ 5306c162-03f3-11eb-3b80-3577af92365c
md"# Rapport du projet d'Implémentation d'algo. de rech. opérationnelle
## Phase 5 : 14/12/2020
Antonin Kenens, Vincent Perreault et Laura Kolcheva
Dépôt github à l'adresse suivante: https://github.com/VincentPerreault0/mth6412b-starter-code/tree/phase5Laura
"

# ╔═╡ 74929e92-3d86-11eb-2bef-271e790eab88
md"###### Il faut noter que tous les tours et photos reconstruites générés dans cette phase sont présents dans: mth6412b-starter-code\projet\phase5\images\solutions"

# ╔═╡ a2bed920-3d70-11eb-1788-bd5385f4a538
md"Nous mettons et cachons ici les méthodes très longues liées aux types de donées Node, Edge, Graph et PriorityQueue ainsi que les fonctions de read_stsp.jl que nous n'avons pas changé depuis la phase précédente."

# ╔═╡ 0e058062-3d7d-11eb-1c2f-35bf63936a6b
md"Nous cachons également ici les algorithmes de Prim, de Rosenkrantz, Stearns et Lewis, de Kruskal et de Held et Karp introduits dans les phases précédentes."

# ╔═╡ adfc7870-3d7e-11eb-17c7-d76f7140dd2a
md" Nous pouvons maintenant expliquer le travail effectué dans la phase 5 et présenter les différentes fontions implémentées."

# ╔═╡ 863e2a70-3e57-11eb-2bf4-0bbc12618312
md" ### Nouvelles fonctions "

# ╔═╡ 1a1785b0-1b68-11eb-0070-8b3453a5c896
md"Nous avons en premier implementé une fonction tour__cost qui renvoie la somme des coûts des arrêtes d'un tour. Cette fonction est testée dans le fichier unit_ _tests_phase5.jl sur l'exemple donné en cours."

# ╔═╡ aa712232-3e57-11eb-2355-5710f0658f9f
md" ### Fonction tsp__ cost"

# ╔═╡ 38e5bb30-03f6-11eb-332a-7161bc93b80e
begin
	""" fonction qui calcule le cout d un tour"""
	function tsp_cost(tour::AbstractGraph)
		cost=0
		for edge in edges(tour)
			cost+=weight(edge)
		end
		return(cost)
	end 
end

# ╔═╡ 84063ae0-1b70-11eb-1407-ff11932e99b6
md" Nous avons ensuite implémenté plusieurs fontions permettant de reconstruire des images 'déchiquetées' à l'aide des fonctions présentent dans le fichier tools,jl. Nous allons en premier introduire ces fonctions en les cachant." 

# ╔═╡ 9f697ea0-3e57-11eb-0017-13e1d8ba3893
md" ### Fonction unshred"

# ╔═╡ cb920f20-3d7f-11eb-3e9a-3384dc2f11db
md"Nous introduison maintenant la première fonction 'unshred' qui prend en entrée le nom d'une image, le boolen hk et le booleen view. Si hk est vrai, on va utiliser l'algorithme de Held et Karp. Sinon on utilise l'algorithme de RSL (tous deux programmés dans la phase 3), Si view est vrai, on affiche l'image reconstruite à la fin. 
Cet algo prend en entrée le nom d'une image à reconstruire. Il utilise le fichier TSP correspondant pour construire une tournée minimale des colonnes de l'image. Ensuite, on utilise la fonction write__ tour de tools.jl pour écrire le nouveau tour et enfin on utilise la fonction reconstruct__ picture de tools.jl pour reconstruire l'image déchiquetée selon le tour définit. 
Nous avons nommé les images sortant de cet algortithme: 'reconstructed_new nom de l'image.png'. 
###### Remarque 1: Les différentes versions de unshred sont identiques si hk=true dans les paramètres. 
###### Remarque 2: On a ajouté 'new' dans le nom des photos et tours pour prendre en compte le changement de la fonction compare_pixels(p1, p2) dont les éléments sont passés en type Float64. Il sera de même pour toutes les fonctions par la suite. Il faut tout de même noter que ce changement ne donne pas de différence pour la reconstruction d'images avec RSL." 

# ╔═╡ 0844bc50-3d81-11eb-0e58-edce2d809d75
md" Afin de faire fonctionner RSL avec les instances TSP fournies, nous avons rendu le poids de toutes les arrêtes partant du noeud 0 plus élevé que le poids de l'arrête la plus la lourde du graphe."

# ╔═╡ 49e6cc70-3d81-11eb-057c-632b5ec8c846
md"##### Remarque:
Nous allons présenter les meilleurs résultats pour chaque image ainsi que la longueur des tours après avoir présenté toutes les fonctions implémentées."


# ╔═╡ bb4dd850-3e57-11eb-029c-cf263fbcd15a
md" ### Fonction unshred__ min"

# ╔═╡ d6b19590-3d81-11eb-349f-6bea185c1046
md"Nous avons voulu améliorer le rendu de la fonction unshred (notamment pour RSL). Nous nous sommes rendu compte que les images étaient bien reconstruite à part une 'coupure' dans l'image reconstruite. Cette 'coupure' correspondait souvent à un des bords de l'image.
Dans un premier temps, on a voulu s'assurer que l'arrête de poids minimum était bien dans le graphe. En effet, avec le noeud 0 et tous les arcs sortant de 0 ayant le même poids, l'algorithme prenait toujours comme source le noeud 1. On a changé ceci en forcant l'algorithme à aller visiter un des noeuds de l'arc à poids minimum. Nous avons donc implémenté la fonction unshred_min qui prend en entrée les mêmes paramètres, qui renvoient un tour et une image reconstruite mais avec la spécificité de visiter l'arc à poids minimal." 

# ╔═╡ 42928200-3d83-11eb-3bfa-332178fd2405
md"Nous nous sommes rendu compte que cette technique n'améliorait pas toujours le résultat donné. De plus, elle ne remédiait pas à la coupure en milieu de l'image."

# ╔═╡ d7451dc0-3e57-11eb-04e7-dde82a1fe8f4
md"### Fonction unshred_mean"

# ╔═╡ d29d4900-3d85-11eb-077b-61cf5ebe96e8
md"Nous avons en premier voulu trouver l'arrête la plus lourde utilisée dans le tour. Logiquement cette arrête devrait être prêt de la coupure. Nous avons implémenté un algorithme qui décale toute l'image vers la droite jusqu'à ce que la colonne après l'arrête la plus longue soit première dans le tour. De même, nous avons essayé de calculer la différence de poids entre les arrêtes consécutive. Nous avons implémenté un algorithme qui décale l'image vers la droite pour que l'arrête avec la différence de poids la plus élevée se retrouve en début de tour. Nous ne mettons pas les algortimes pour ces deux fonctions ici parce qu'ils n'ont pas donné de bons résultats. On se retouvait souvent avec deux 'coupures' en milieu d'image plutôt qu'une. "

# ╔═╡ c33c8480-3d85-11eb-1b82-31de9c53481f
md"Nous avons alors eu le raisonnement suivant. Les colonnes du bord doivent, en moyenne, être plus différentes de l'ensemble des autres colonnes, que les colonnes en milieu de photo. Nous avons donc implémenté la fonction unshred__ mean qui, de la même manière que unshred_min, force l'algorithme de tournée minimale à commencer par le noeud le plus éloigné en moyenne de tous les autres noeuds. Cet algorithme a souvent amélioré le résultat obtenu, ou a du moins décalé les coupures vers les bors des images."

# ╔═╡ 90c6d7e0-3d84-11eb-302f-2748b11b08fc
md"Encore une fois, on n'a pas de fonction qui donne des meilleurs résultats pour toutes les photos. Le problème de la coupure en milieu d'image persistait. Nous nous sommes rendu compte que pour le cas de RSL cette coupure en milieu d'image était souvent due à un passage du sous-abre gauche au sous-arbre de droite pour une noeud décisif, mais pas forcément de la racine. Nous avons du mal à identifier ce noeud par un algorithme. Nous avons donc essayé d'implémenter un algorithme de 2-opt, que nous n'avons pas réussi à faire fonctionner sans qu'il soit trop couteux. En effet, nos structures de données n'étaient pas adaptées à la représentation d'un tour hamiltonien avec des indices entre noeuds consécutifs (lors des changements d'indice, le sens de lecture des noeuds peut changer et ceci rend le code plus difficile)."

# ╔═╡ 8ce8c670-3d9c-11eb-1166-9fd188a544ef
md" ### Résultats: 
Nous allons maintenant présenter les résultats des algorithmes, ainsi que les meilleurs solutions selon nous. Il faut tout d'abbord importer certains packages." 

# ╔═╡ 88413430-3d98-11eb-1da1-cf95185813b4
md"#### Image abstract light painting
Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont effectués avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred_min, qui semble identique à l'originale. Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ 0caa3b80-3d90-11eb-04c2-a32700d33403
begin
	img0=[load("../phase5/images/original/abstract-light-painting.png"),load("../phase5/images/solutions/reconstructed_new_min_abstract-light-painting.png"),load("../phase5/images/solutions/reconstructed_new_abstract-light-painting.png"),load("../phase5/images/solutions/reconstructed_new_mean_abstract-light-painting.png")] 
	p0=plot(layout = 4, size = (670,600),title=["original" "unshred_min" "unshred" "unshred_mean"])
	for i in 1:4
		plot!(p0[i], img0[i])
	end
	p0
end

# ╔═╡ 07c36a70-3d99-11eb-1dc1-cf865d9dde7d
md"#### Image alaska railroad
Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont effectuées avec RSL. La meilleure image trouvée est l'image de l'algorithme unshred__ min, même si toutes les images sont inversées. L'image données par unshred_min a la plus petite coupure en deux. Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ 0ca83fb0-3d90-11eb-1492-d969b1923c3f
begin
	img1=[load("../phase5/images/original/alaska-railroad.png"),load("../phase5/images/solutions/reconstructed_new_min_alaska-railroad.png"),load("../phase5/images/solutions/reconstructed_new_alaska-railroad.png"),load("../phase5/images/solutions/reconstructed_new_mean_alaska-railroad.png")] 
	p1=plot(layout = 4, size = (670,600),title=["original" "unshred_min" "unshred" "unshred_mean"])
	for i in 1:4
		plot!(p1[i], img1[i])
	end
	p1
end

# ╔═╡ 0ca5f5c0-3d90-11eb-1036-bf524ca6f20c
md"#### Image Blue hour Paris 
Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont faits avec RSL. La meilleure image trouvée est l'image de l'algorithme unshred__ min. Nous avons hésité entre unshred__ min et unshred__ mean pour la meilleure image comme unshred__ mean donne une image non inversée, mais finalement le coût du tour dans unshred__ min est plus faible (unshred__ min : 4.210692e6 contre 4.264599e6 pour unshred__ mean). Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ 0ca24c40-3d90-11eb-1afa-99103556f46a
begin
	img2=[load("../phase5/images/original/blue-hour-paris.png"),load("../phase5/images/solutions/reconstructed_new_min_blue-hour-paris.png"),load("../phase5/images/solutions/reconstructed_new_blue-hour-paris.png"),load("../phase5/images/solutions/reconstructed_new_mean_blue-hour-paris.png")] 
	p2=plot(layout = 4, size = (670,600),title=["original" "unshred_min" "unshred" "unshred_mean"])
	for i in 1:4
		plot!(p2[i], img2[i])
	end
	p2
end

# ╔═╡ 0ca02960-3d90-11eb-2bbf-99ab05bf402e
md"#### Image lower kananaskis lake
Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont faits avec RSL. La meilleure image trouvée est l'image de l'algorithme unshred__ min. Encore une fois, nous avons hésité entre unshred__ min et unshred__ mean pour la meilleure image. Le score de unshred__ min reste meilleur. 
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ c04aaf2e-3d9a-11eb-1016-f354cda5b67c
begin
	img3=[load("../phase5/images/original/lower-kananaskis-lake.png"),load("../phase5/images/solutions/reconstructed_new_min_lower-kananaskis-lake.png"),load("../phase5/images/solutions/reconstructed_new_lower-kananaskis-lake.png"),load("../phase5/images/solutions/reconstructed_new_mean_lower-kananaskis-lake.png")] 
	p3=plot(layout = 4, size = (670,600),title=["original" "unshred_min" "unshred" "unshred_mean"])
	for i in 1:4
		plot!(p3[i], img3[i])
	end
	p3
end

# ╔═╡ 6b9c4240-3d9b-11eb-1176-333e0fce5492
md"#### Image marlet2 radio board
Ceci est peut-être l'image la plus difficile à reconstruire. Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont faits avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred__ mean.Nous avons hésité entre unshred__ mean et unshred pour la meilleure image. Le score de unshred__ mean est légérement meilleur (9.362476e6 pour unshred__ mean contre 9.369582e6 pour unshred). Par conte, on estime qu'à l'oeil nu on remarque moins les défauts dans l'image rendue par unshred.
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ c11053b0-3d9b-11eb-21d8-a7d6271cde98

begin
	img4=[load("../phase5/images/original/marlet2-radio-board.png"),load("../phase5/images/solutions/reconstructed_new_mean_marlet2-radio-board.png"),load("../phase5/images/solutions/reconstructed_new_marlet2-radio-board.png"),load("../phase5/images/solutions/reconstructed_new_min_marlet2-radio-board.png")] 
	p4=plot(layout = 4, size = (670,600),title=["original" "unshred_mean" "unshred" "unshred_min"])
	for i in 1:4
		plot!(p4[i], img4[i])
	end
	p4
end

# ╔═╡ b1cf08a0-3d9c-11eb-048a-a7a26b755ca4
md"#### Image nikos cat
 Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont faits avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred__ mean qui semble identique à l'originale. 
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ b27d981e-3d9c-11eb-3968-7b5936c83035
begin
	img5=[load("../phase5/images/original/nikos-cat.png"),load("../phase5/images/solutions/reconstructed_new_mean_nikos-cat.png"),load("../phase5/images/solutions/reconstructed_new_min_nikos-cat.png"),load("../phase5/images/solutions/reconstructed_new_nikos-cat.png")] 
	p5=plot(layout = 4, size = (670,600),title=["original" "unshred_mean" "unshred_min" "unshred"])
	for i in 1:4
		plot!(p5[i], img5[i])
	end
	p5
end

# ╔═╡ 5c544b00-3d9d-11eb-330e-5b5d56e81dab
md"#### Image pizza food wallpaper
Pour les images suivantes, tous les tours sont longs de 601 noeuds et sont fait avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred, même si elle est inversée par rapport à l'originale. Les deux autres algortihmes donnent une image avec une coupure relativement abrupte.
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ 51b63eb0-3d9d-11eb-3f9f-bb2ba196a519
begin
	img6=[load("../phase5/images/original/pizza-food-wallpaper.png"),load("../phase5/images/solutions/reconstructed_new_pizza-food-wallpaper.png"),load("../phase5/images/solutions/reconstructed_new_min_pizza-food-wallpaper.png"),load("../phase5/images/solutions/reconstructed_new_mean_pizza-food-wallpaper.png")] 
	p6=plot(layout = 4, size = (670,600),title=["original" "unshred" "unshred_min" "unshred_mean"])
	for i in 1:4
		plot!(p6[i], img6[i])
	end
	p6
end

# ╔═╡ cf1a28d0-3d9d-11eb-2202-f378bcaf1a18
md"#### Image the enchanted garden
Pour les images suivantes, tous les tours sont longs de 601 noeuds (en comptant le noeud 0) et sont faits avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred_mean, même si elle est inversée par rapport à l'originale.
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ cd7c0930-3d9d-11eb-2326-198d8bf4fbda
begin
	img7=[load("../phase5/images/original/the-enchanted-garden.png"),load("../phase5/images/solutions/reconstructed_new_mean_the-enchanted-garden.png"),load("../phase5/images/solutions/reconstructed_new_min_the-enchanted-garden.png"),load("../phase5/images/solutions/reconstructed_new_the-enchanted-garden.png")] 
	p7=plot(layout = 4, size = (670,600),title=["original" "unshred_mean" "unshred_min" "unshred"])
	for i in 1:4
		plot!(p7[i], img7[i])
	end
	p7
end

# ╔═╡ 5d699620-3d9e-11eb-0a05-f9c603ab3a6d
md"#### Image tokyo skytree aerial
Pour les images suivantes, tous les tours sont longs de 601 noeuds (en comptant le noeud 0) et sont faits avec RSL.
La meilleure image trouvée est l'image de l'algorithme unshred. Les 3 images produites ne donnent pas de résultats satisfaisants. 
Nous avons mis les images des deux autres algorithmes pour indication."

# ╔═╡ 6652785e-3d9e-11eb-39a6-1f15754d9664
begin
	img8=[load("../phase5/images/original/tokyo-skytree-aerial.png"),load("../phase5/images/solutions/reconstructed_new_tokyo-skytree-aerial.png"),load("../phase5/images/solutions/reconstructed_new_mean_tokyo-skytree-aerial.png"),load("../phase5/images/solutions/reconstructed_new_min_tokyo-skytree-aerial.png")] 
	p8=plot(layout = 4, size = (670,600),title=["original" "unshred" "unshred_mean" "unshred_min"])
	for i in 1:4
		plot!(p8[i], img8[i])
	end
	p8
end

# ╔═╡ f1cea170-3d9e-11eb-3e52-41511958432e
md"#### En conclusion
L'agorithme unshred__ min se comporte le mieux pour 4 images sur 9, unshred__ mean se comporte le mieux pour 3 images sur 9 et finalement unshred se comporte le mieux pour 2 images.Tous ces résultats ont été obtenus avec RSL et non Held et Karp. 
L'algorithme de Held et Karp converge, mais trop lentement. "


# ╔═╡ 82af7be2-3e4b-11eb-1d4a-c317530fc377
md"### Optimisation de Held Karp et temps d'éxecution des algorithmes"

# ╔═╡ 895af140-3e4b-11eb-0378-9310f3a64db3
md"Comme la reconstitution d'images fonctionnait très bien aves RSL mais avait quelques légers défauts, nous avons tenté de le lancer avec Held Karp. Cependant le temps d'éxecution était beaucoup trop important. C'est pourquoi nous avons établi des tests afin d'améliorer le temps d'éxecution de Held Karp"

# ╔═╡ 8b6455d0-3e4b-11eb-0ed7-d52b1576f65e
md"#### Temps d'éxecutions des algorithmes"

# ╔═╡ 927802de-3e4b-11eb-0286-f3a7c3f5ed1f
md"Nous avons créé le fichier hk_optimization qui établit le temps d'éxecution de toutes les fonctions utilisé par Held Karp dont le code est disponible ci-dessous :"

# ╔═╡ 18bce000-3e4c-11eb-2746-3f46b5699ed7
md"On rajoute en premier Connected Component et find__ minimum__ spanning__ tree des phases précédentes. On les cache comme on ne les a pas modifié."

# ╔═╡ 87986440-3e4c-11eb-0465-89e18c88ed09
begin
	mutable struct ConnectedComponent{T} <: AbstractGraph{T}
	  name::String
	  nodes::Vector{Node{T}}
	  edges::Vector{Edge}
	end

	"""Type representant une composante connexe comme un graphe.

	Exemple :

	  node1 = Node("Joe", 3.14)
	  node2 = Node("Steve", exp(1))
	  node3 = Node("Jill", 4.12)
	  edge1 = Edge(500, (node1, node2))
	  edge2 = Edge(1000, (node2, node3))
	  CC = ConnectedComponent("Ick", [node1, node2, node3], [edge1, edge2])

	Attention, tous les noeuds doivent avoir des données de même type.
	"""

	"""Crée une composante connexe à partir d'un noeud."""
	create_connected_component_from_node(node::Node{T}) where T = ConnectedComponent{T}("Connected component containing node " * node.name,[node],[])

	"""Calcule le nombre de noeuds d'un lien contenus dans la composante connexe."""
	function contains_edge_nodes(c_component::ConnectedComponent{T}, edge::Edge) where T
	  nb_nodes_contained = 0
	  for node in nodes(edge)
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

# ╔═╡ 22c11e60-3d7d-11eb-3143-ad73b73d5a59
begin
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
	
	"""" fonction qui prend un graphe et une source et renvoie
	un minimal spanning tree par l algorithme de Prim"""
	function prim(graph :: AbstractGraph, s :: AbstractNode)
		if (s in nodes(graph))==false
			println("la source doit etre un noeud du graphe")
			return
		end
		#initialisation des listes
		new_edges=Edge[]
		s.minweight=0
		q=PriorityQueue{Node}()
		p=PriorityQueue{Edge}()

		#initialisation des dictionnaires contenant les listes d adjacences des noeuds
		#et les arretes incidentes pour chaque noeud
		dict_edges=Dict{Node, Vector{Edge}}()
		dict_nodes=Dict{Node, Vector{Node}}()
		for node in nodes(graph)
			dict_edges[node]=Edge[]
			dict_nodes[node]=Node{typeof(node)}[]
			add_item!(q,node)
		end

		# Calcul des listes d adjacence
		for edge in edges(graph)
			node1=nodes(edge)[1]
			node2=nodes(edge)[2]
			push!(dict_nodes[node1],node2)
			push!(dict_nodes[node2],node1)
			push!(dict_edges[node1],edge)
			push!(dict_edges[node2],edge)
		end
		#Boucle
		while nb_items(q)>0
			#on sort un noeud de minweight minimal
			u=popfirst!(q, Node)
			#on ajoute l arrete correspondante aux arretes du minimum spanning tree
			if (u==s)==false #si u!==s on est a la premiere iteration et p est vide
				tmp=popfirst!(p,u)
				push!(new_edges,tmp)
			end
			#on actualise les valeurs des noeuds voisins
			for v in dict_nodes[u]
				if contains_item(q,v)==true
					for edge in dict_edges[v]                  
						if u in nodes(edge) && weight(edge)<minweight(v)
							v.parent=u
							v.minweight=weight(edge)
							add_item!(p,edge)
						end
					end
				end
			end
		end
		return(Graph("Minimum Spanning tree from Prim alg of "*name(graph), nodes(graph), new_edges))
	end

	""" fonction qui prend en entree un noeud, les listes d'adjacences d un arbre, et un vecteur de noeuds ordonne et rajouter au vecteurordonne les noeuds en preordre de cet arbre (parcours du noeud puis parcours des enfants).
	Cette fonction modifie la liste d'adjcence au fur et a mesure pour parcourir chaque noeud une unique fois"""
	function find_children(s:: Node{T}, dict_edges:: Dict{Node, Vector{Edge}}, q:: Vector{Node{T}}) where T
		push!(q,s)
		if length(dict_edges[s])==0
			return(q)
		else
			for edge in dict_edges[s]
				node1,node2=nodes(edge)
				if (node1==s)==false
					filter!(x -> x != edge, dict_edges[node1])
					q=find_children(node1,dict_edges,q)
				else 
					filter!(x -> x != edge, dict_edges[node2])
					q=find_children(node2,dict_edges,q) 
				end
			end
		end
		return(q)
	end

	""" fonction qui prend en entree un graphe et une racine et renvoie en vecteur une proposition de tournee pour le TSP lie a ce graphe.
	On utilise l algorithme de Prim pour construite un arbre de recouvrement minimal
	Les arretes adjacentes de chaque noeud sont parcourues en ordre croissant des poids, du fait de l'ordre des arretes renvoye par l algorithme de Prim"""
	function rsl(graph::AbstractGraph, s::AbstractNode)
		mst=prim(graph,s)
		dict_edges=Dict{Node, Vector{Edge}}()
		for node in nodes(mst)
			dict_edges[node]=Edge[]
		end
		for edge in edges(mst)
			node1=nodes(edge)[1]
			node2=nodes(edge)[2]
			push!(dict_edges[node1],edge)
			push!(dict_edges[node2],edge)
		end
		q=find_children(s,dict_edges,Vector{typeof(s)}())
		return(q)
	end

	"""get weight of rsl"""
	function rsl_graph_weight(graph :: AbstractGraph, ar_nodes :: Array)
		g_edges = edges(graph)
		len_n = length(ar_nodes)
		len_e = length(g_edges)
		rsl_weight = 0

		for i = 1:(len_n-1)
			for j = 1 : len_e
				if (ar_nodes[i] in(nodes(g_edges[j])) && ar_nodes[i+1] in(nodes(g_edges[j])))
					rsl_weight = rsl_weight + weight(g_edges[j])
				end
			end
		end
		for j = 1 : len_e
			if (ar_nodes[1] in(nodes(g_edges[j])) && ar_nodes[len_n] in(nodes(g_edges[j])))
				rsl_weight = rsl_weight + weight(g_edges[j])
			end
		end
		return rsl_weight
	end

	import LinearAlgebra.dot
	import LinearAlgebra.norm

	"""Creation of subgraph from graph without node s"""
	function sub_graph(graph :: AbstractGraph, s :: AbstractNode)
		# On récupère les valeurs nécessaires et on initialise les autres
		g_edges = edges(graph)
		g_nodes = nodes(graph)
		sub_nodes = typeof(s)[]
		sub_edges = Edge[]
		# On récupère tous les sommets sauf celui choisi
		for i = 1 : length(g_nodes)
			if g_nodes[i] != s
				push!(sub_nodes,g_nodes[i])
			end
		end
		# on récupère toutes les arêtes sauf celles contenant le noeud
		for i = 1 : length(g_edges)
			if !(s in(nodes(g_edges[i])))
				push!(sub_edges,g_edges[i])
			end
		end
		return Graph("sub_graph s", sub_nodes, sub_edges)
	end

	"""Getting the 2 min edges weight in a graph with node s
		needs at least 2 edges connected to s"""
	function min_weight_edges(graph :: AbstractGraph, s :: AbstractNode)
		medges = edges(graph)
		edge1 = nothing
		edge2 = nothing
		# On récupère les premières arêtes contenant le noeud s
		for i = 1 : length(medges)
			if (s in(nodes(medges[i]))) && (edge1 === nothing) && (edge2 === nothing) && (nodes(medges[i])[1] != nodes(medges[i])[2])
				edge1 = medges[i]
			elseif (s in(nodes(medges[i]))) && (edge2 === nothing) && (nodes(medges[i])[1] != nodes(medges[i])[2])
				edge2 = medges[i]
			end
		end
		# On parcourt toutes les arêtes reliés à s et on prend celles de poids minimal
		for i = 1 : length(medges)
			if (s in(nodes(medges[i])) && medges[i] != edge1 && medges[i] != edge2 && (nodes(medges[i])[1] != nodes(medges[i])[2]))
				if (weight(medges[i]) < weight(edge1) || weight(medges[i]) < weight(edge2))
					if weight(edge1) < weight(edge2)
						edge2 = edge1
					end
					edge1 = medges[i]
				end
			end
		end
		return [edge1,edge2]
	end

	"""Creating min 1-tree from node s1 and prim algorithm used with s2"""
	function min_one_tree_two_nodes(graph :: AbstractGraph, s1 :: AbstractNode, s2 :: AbstractNode)
		node_num = get_node_num(s1)
		if node_num == 0
			set_node_numbers!(graph)
			node_num = get_node_num(s1)
		end
		sgraph = sub_graph(graph,s1)
		mst_prim = prim(sgraph, s2)
		mw_edges = min_weight_edges(graph, s1)
		insert_node!(mst_prim, node_num, s1)
		add_edge!(mst_prim,mw_edges[1])
		add_edge!(mst_prim,mw_edges[2])
		return mst_prim
	end

	"""Creating min 1-tree from node s1 and prim or kruskal algorithm"""
	function min_one_tree(graph :: AbstractGraph, s1 :: AbstractNode, krusk :: Bool, randnode :: Bool)
		# On vérifie que les sommets ont bien un numéro attribué
		node_num = get_node_num(s1)
		if node_num == 0
			set_node_numbers!(graph)
			node_num = get_node_num(s1)
		end
		sgraph = sub_graph(graph,s1)
		# On choisit entre prendre un noeud aléatoire ou le premier noeud
		# ( n'a d'intérêt que pour l'algorithme prim )
		if randnode == true
			# Random node of graph
			max_val = nb_nodes(sgraph)
			node_num = rand(1:max_val)
			node_prim = nodes(sgraph)[node_num]
		else
			# First node of graph
			node_prim = nodes(sgraph)[1]
		end
		# On choisit entre l'algorithme prim et l'algorithme kruskal
		if krusk == true
			# Mst with kruskal
			mst = find_minimum_spanning_tree(sgraph, false)
		else
			# Mst with prim
			mst = prim(sgraph, node_prim)
		end
		# On récupère les min edges et on rajoute le noeud initial
		mw_edges = min_weight_edges(graph, s1)
		insert_node!(mst, node_num, s1)
		add_edge!(mst,mw_edges[1])
		add_edge!(mst,mw_edges[2])
		# L'algorithme de Kruskal renvoyant les noeuds dans le désordre,
		# On les range à nouveau
		if krusk == true
			order_nodes!(mst)
		end
		return mst
	end

	"""Add pi weight to graph edges"""
	function add_pi_graph!(graph::AbstractGraph, pi::Array)
		g_edges = edges(graph)
		old_weights = []
		for i = 1 : length(g_edges)
			edge_n = get_edge_node_nums(g_edges[i])
			# On vérifie que les numéros sont bien attribués aux sommets
			if edge_n[1] == 0
				println("Don't forget to set node numbers")
			end
			# On ajoute les nouvelles valeurs de pi
			push!(old_weights,weight(g_edges[i]))
			new_weight = weight(g_edges[i]) + pi[edge_n[1]] + pi[edge_n[2]]
			set_weight!(g_edges[i], new_weight)
		end
		# On renvoie les anciennes valeurs exactes des poids pour limiter
		# Les erreurs de calcul occasionnées par les effets de bords
		return old_weights
	end

	"""Substract pi weight to graph edges"""
	function sub_pi_graph!(graph::AbstractGraph, old_weights::Array)
		# On récupère les anciennes valeurs de poids données par add_pi_graph
		g_edges = edges(graph)
		for i = 1 : length(g_edges)
			set_weight!(g_edges[i], old_weights[i])
		end
	end

	"""Checking if a minimum 1-tree is a tour"""
	function is_tour(graph :: AbstractGraph)
		otree_degrees = degrees(graph)
		# On vérifie simplement si les degrés sont différents de 2
		for i = 1 : length(otree_degrees)
			if otree_degrees[i] != 2
				return false
			end
		end
		return true
	end

	"""W function as described in TSP doc"""
	function w_one_trees(graph :: AbstractGraph, pi :: Array, krusk :: Bool, randnode :: Bool)
		# On initialise toutes les variables nécessaires
		nb_iterations = nb_nodes(graph)
		g_nodes = nodes(graph)
		node_num = get_node_num(g_nodes[1])
		if node_num == 0
			set_node_numbers!(graph)
		end
		min_wk = nothing
		min_vk = nothing
		min_kth_otree = graph
		old_weights = []

		# On détermine tous 1-tree possibles ( 1 par node )
		for k = 1 : nb_iterations
			# On limite les effets de bords en remettant toutes les
			# valeurs du graphe à 0
			reset_graph!(graph)

			# On ajoute les valeurs de pi au poids des edges
			old_weights = add_pi_graph!(graph,pi)

			# On détermine le 1-tree minimal par rapport au point k
			kth_otree = min_one_tree(graph,g_nodes[k],krusk,randnode)

			# On soustrait les valeurs de pi
			sub_pi_graph!(graph,old_weights)

			# On calcule c_k
			ck = total_weight(kth_otree)

			# On calcule le produit pi.vk       
			sum_pi_vk = 0
			otree_degrees = degrees(kth_otree)
			vk = otree_degrees .- 2
			sum_pi_vk = dot(pi,vk)

			# On obtient la valeur de w pour la k-ieme iteration
			wk = ck + sum_pi_vk

			# On détermine la valeur minimale de wk
			# ( et le vk et kieme 1-tree associé )
			if min_wk === nothing || wk <= min_wk
				min_wk = wk
				min_vk = vk
				min_kth_otree = kth_otree
			end
		end
		# On renvoie le min de wk
		# ( et le vk et kieme 1-tree associé )
		return min_wk, min_vk, min_kth_otree
	end

	"""Getting the maximum value of w"""
	function max_w(graph :: AbstractGraph, tm :: Float64, max_iter :: Int64, pi_m :: Array, krusk :: Bool, randnode :: Bool)
		# On initialise les variables
		iter = 0
		n_tour = 1
		min_tour = graph
		w_ref = 0
		max_wk = 0
		# Dans cette version la limite est un nombre limite d'itérations
		while iter < max_iter
			wk, vk, k_otree = w_one_trees(graph,pi_m,krusk,randnode)
			pi_m = pi_m + tm .* vk
			iter = iter + 1
			if is_tour(k_otree)
				return k_otree, wk
			end
			if wk > max_wk
				max_wk = wk
				min_tour = k_otree
			end
			#if wk < w_ref
			#    tm = tm / 2
			#elseif wk > w_ref
			#    tm = min(20.0,tm*2)
			#end
			w_ref = wk
		end
		return min_tour, max_wk
	end

	"""Getting the maximum value of w according to LK"""
	function max_w_lk(graph :: AbstractGraph, tm :: Float64, max_iter :: Int64, pi_m :: Array, krusk :: Bool, randnode :: Bool)

		# On initialise les variables
		iter = 0
		size_g = nb_nodes(graph)
		min_tour = graph
		null_step_size = false
		null_period = false
		null_vk = false
		period = size_g ÷ 2
		period_iter = 0
		w_ref = 0
		vk_ref = []
		first_period = true
		max_wk = 0

		while !null_step_size && !null_period && !null_vk && iter < max_iter     

			(wk, vk, k_otree) = w_one_trees(graph,pi_m,krusk,randnode)
			# wk est ici calculé à partir de vk et vk-1
			if iter == 0
				vk_ref = vk
			end
			pi_m = pi_m + tm .*(0.7.*vk+0.3.*vk_ref)
			if is_tour(k_otree)
				println("yesssss")
				min_tour = k_otree
			end
			period_iter = period_iter + 1
			iter = iter + 1

			# End loop update
			if wk > w_ref && period_iter == period 
				period = period*2
				first_period = false
			elseif period_iter == period
				period_iter = 0
				period = period ÷ 2
				tm = tm/2
				first_period = false
			end
			if wk > w_ref && period == size_g ÷ 2 && first_period
				tm = tm*2
			end
			w_ref = wk
			vk_ref = vk
			if wk > max_wk
				max_wk = wk
				min_tour = k_otree
			end

			# End condition update
			null_step_size = (tm < 0.001)
			null_period = (period < 0.001)
			null_vk = (vk == zeros(size_g))

		end
		return min_tour, max_wk
	end

	# Fonctions ci-dessous corrigées après l'heure limite de rendu :
	# Elle permet de récupérer un 1-tree qui est quasiment un tour et de le transformet en tour
	# Ne fonctionne que sur des 1-tree qui ont des degrés égaux à 1, 2 ou 3
	"""Correct 1-tree into tour, with a given amount of corrections"""
	function correct_one_tree(graph :: AbstractGraph, one_tree :: AbstractGraph, num_of_cor :: Int64)

		o_nodes = nodes(one_tree)
		o_edges = edges(one_tree)

		ot_deg_one = typeof(o_nodes[1])[]
		index = 1

		num_cor_done = 0

		while num_of_cor != num_cor_done
			if ((degree(one_tree, nodes(o_edges[index])[1]) == 3 && degree(one_tree, nodes(o_edges[index])[2]) == 2) || (degree(one_tree, nodes(o_edges[index])[2]) == 3  && degree(one_tree, nodes(o_edges[index])[1]) == 2))
				deleteat!(o_edges, findfirst(x->x==o_edges[index], o_edges))
				num_cor_done = num_cor_done + 1
				index = index - 1
			end
			index = index + 1
		end

		for i = 1:length(o_nodes)
			if (degree(one_tree, o_nodes[i])==1)
				push!(ot_deg_one, o_nodes[i])
			end
		end

		if length(ot_deg_one) % 2 != 0
			println("Problème insoluble")
		end

		for i = 1:(length(ot_deg_one) ÷ 2)
			new_edge = find_edge(graph, ot_deg_one[2*i-1], ot_deg_one[2*i])
			add_edge!(one_tree, new_edge)
		end

		return one_tree
	end

	"""Function to get edge with 2 nodes in graph"""
	function find_edge(graph :: AbstractGraph, node1 :: Node{T}, node2 :: Node{T}) where T
		g_edges = edges(graph)
		for i = 1:length(g_edges)
			if (node1 in(nodes(g_edges[i])) && node2 in(nodes(g_edges[i])))
				return g_edges[i]
			end
		end
	end

	"""Function to determine if the 1-tree can be corrected and if so , corrects it"""
	function get_tour(graph :: AbstractGraph, one_tree :: AbstractGraph)
		num_of_cor = 0
		deg_otree = degrees(one_tree)
		for i = 1:length(deg_otree)
			if deg_otree[i] >= 4
				return one_tree
			elseif deg_otree[i] == 3
				num_of_cor = num_of_cor + 1
			end
		end
		graph_tour = correct_one_tree(graph, one_tree, num_of_cor)
		return graph_tour
	end
end

# ╔═╡ e779eb3e-3d7f-11eb-3983-379a480d35a9
""" fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances."""
function unshred(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 1.0 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        m=0
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            if weight(edge)>m
                m=weight(edge) 
            end
        end
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end

    #Step 4: Write tour
    if hk
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_hk_new_tour.txt"
    else
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_tour.txt"
    end
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    if hk
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_hk_new_"*name(graph)*".png"; view)
    else
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_"*name(graph)*".png"; view)
    end
end 

# ╔═╡ 2f4763f0-3d83-11eb-19ef-cb3e2696b7a0
""" fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances. On force le tour de commencer par un des noeuds de l'arc de poids minimal"""
function unshred_min(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 1.0 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        m=0
        mi=1000000
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            if weight(edge)>m
                m=weight(edge) 
            end
            if weight(edge)<mi &&weight(edge)>0
                mi=weight(edge)
                edge_tmp=edge
            end
        end
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        node1=nodes(edge_tmp)[1]
        indice=parse(Int64,name(node1))
        edges(graph)[indice].weight=m+1
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end

    #Step 4: Write tour
    if hk
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_hk_new_min_tour.txt"
    else
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_min_tour.txt"
    end
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    if hk
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_hk_new_min_"*name(graph)*".png"; view)
    else
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_min_"*name(graph)*".png"; view)
    end 
end 

# ╔═╡ 82bd6600-3d84-11eb-167f-47a00a1325a4
"""fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances. On force le tour a commencer qui est le plus loin en moyenne des autres noeuds"""
function unshred_mean(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 1.0 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        dict_edges=Dict{Node, Vector{Edge}}()
        for node in nodes(graph)
            dict_edges[node]=Edge[]
        end
        m=0
        mi=1000000
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            push!(dict_edges[nodes(edge)[1]],edge)
            push!(dict_edges[nodes(edge)[2]],edge)
            if weight(edge)>m
                m=weight(edge) 
            end
        end
        arr=Vector{Float64}()
        for node in nodes(graph)
            s=0
            for edge in dict_edges[node]
                s+=weight(edge)
            end 
            s=s/600
            push!(arr, s)
        end 
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        indice=argmax(arr)
        edges(graph)[indice].weight=m+1
        
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end
    #Step 4: Write tour
    if hk
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_hk_new_mean_tour.txt"
    else
        tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_mean_tour.txt"
    end
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    if hk
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_hk_new_mean_"*name(graph)*".png"; view)
    else
        reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_mean_"*name(graph)*".png"; view)
    end
end 

# ╔═╡ 97cac612-3e4b-11eb-2f90-59e6235e1749
begin
	filenamegr21 = "instances/stsp/gr21.tsp"
	filename561 = "instances/stsp/pa561.tsp"
	filenamebhp = "../phase5/tsp/instances/blue-hour-paris.tsp"

	graph = create_graph_from_stsp_file(filenamebhp, false)
	println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")

	nbn = nb_nodes(graph)
	randval = rand(1:nbn)
	randnode = nodes(graph)[randval]
	randedge = edges(graph)[randval]
	pi1 = zeros(nbn)
	pi2 = ones(nbn)

	println("time subgraph :")
	@time sub_graph(graph,randnode)

	println("time min weight edges :")
	@time min_weight_edges(graph,randnode)

	#println("time min_weight_edges2 :")
	#@time min_weight_edges2(graph,randnode)

	println("time set_node_numbers :")
	@time set_node_numbers!(graph)

	println("time order_nodes :")
	@time order_nodes!(graph)

	println("time reset_graph :")
	@time reset_graph!(graph)

	println("time get_edge_node_nums :")
	@time get_edge_node_nums(randedge)

	println("time add_pi_graph :")
	@time old_weights = add_pi_graph!(graph,pi2)

	println("time sub_pi_graph :")
	@time sub_pi_graph!(graph,old_weights)

	println("time mst krusk :")
	@time find_minimum_spanning_tree(graph, false)

	println("time mst prim")
	@time prim(graph, randnode)

	println("time min_one_tree :")
	@time min_one_tree(graph,randnode, true, false)

	reset_graph!(graph)

	println("time w_one_trees :")
	@time w_one_trees(graph, pi1, true, false)
end

# ╔═╡ 142f68a0-3e4c-11eb-1e8f-31845d2ea77e
md"En particulier sur le graphe blue-hour-paris il nous donne les résultats suivants :"

# ╔═╡ 9f7df200-3e4c-11eb-1605-9713851b02f1
Graph blue-hour-paris has 601 nodes and 180300 edges.
time subgraph :
  0.056816 seconds (39.00 k allocations: 5.103 MiB)
time min weight edges :
  0.140259 seconds (204.01 k allocations: 11.088 MiB, 25.98% gc time)
time set_node_numbers :
  0.018377 seconds (17.42 k allocations: 988.158 KiB)
time order_nodes :
  0.023576 seconds (20.29 k allocations: 1.121 MiB)
time reset_graph :
  0.014237 seconds (20.77 k allocations: 1.150 MiB)
time get_edge_node_nums :
  0.000004 seconds (1 allocation: 16 bytes)
time add_pi_graph :
  0.106312 seconds (1.16 M allocations: 21.786 MiB)
time sub_pi_graph :
  0.023968 seconds (15.53 k allocations: 871.424 KiB)
time mst krusk :
  0.585060 seconds (728.50 k allocations: 38.654 MiB, 7.06% gc time)
time mst prim
 15.323917 seconds (1.76 M allocations: 96.759 MiB, 1.85% gc time)
time min_one_tree :
  0.164156 seconds (72.03 k allocations: 7.414 MiB)
time w_one_trees :
105.771334 seconds (686.98 M allocations: 14.418 GiB, 3.58% gc time)

# ╔═╡ b235f7d0-3e4c-11eb-0ebf-696aab618714
md"#### Interprétation des résultats"

# ╔═╡ b8a575a0-3e4c-11eb-0836-092cb6f1b34a
md"Afin d'utiliser les résultats précédents de manière pertinente, il est crucial de comprendre le fonctionnement de Held Karp et quelles sont les fonctions pour lesquelles il est le plus important d'améliorer les résultats."

# ╔═╡ c3d07fb0-3e4c-11eb-1d1a-7bf2b3eee17d
md"La fonction w\_one\_trees a une boucle principale qui appelle elle même 3 fonctions principales : add\_pi\_graph, min\_one\_tree et sub\_pi\_graph. Là encore, mis à part ces 3 fonctions w\_one\_trees peut difficilement être améliorée."

# ╔═╡ ca669850-3e4c-11eb-16ab-43dde517ae6e
md"Les fonctions add\_pi\_graph et sub\_pi\_graph contiennent toutes 2 une boucle avec des opérations élémentaires irréductibles donc on peut difficilement les améliorer. Nous avons cependant enlevé un test if inutile dans add\_pi\_graph mais l'impact sur le temps d'éxecution est imperceptible (sauf éventuellement sur des très gros calculs)." 

# ╔═╡ d1426c7e-3e4c-11eb-0a83-1db87ffbb917
md"Il reste désormais la fonction min\_one\_tree. Mis à part quelques conditions qui pourraient être enlevées pour un gain minime mais au détriment d'une facilité de lisibilité, 2 éléments sont ici très importants : le calcul avec l'algorithme de Prim ou Kruskal et la fonction min\_weight\_edges."

# ╔═╡ d880fa20-3e4c-11eb-1237-2b1537e7e3b6
md"Sur les tests effectués, l'algorithme de Kruskal semble bien plus performant que celui de Prim. Par ailleurs, peu importe lequel des deux on choisit, il s'agit de la principal source de temps de calcul de l'algorithme de Held Karp. Pourtant, après lecture des 2 algorithmes, il n'y a pas de boucle superflue donc dans le meilleur des cas, on pourrait espérer améliorer seulement d'un assez faible pourcentage les résultats."

# ╔═╡ dcb04bf0-3e4c-11eb-3cf7-d5651761b8fb
md"D'après les tests effectués, la fonction min\_weight\_edges a un temps d'éxecution assez important par rapport à la tâche qu'elle est censée effectuer. Nous avons donc créé une nouvelle version qui a un temps d'éxecution de 80% par rapport à la première version ( environ 0.10 secondes contre 0.12 secondes avant sur un même graphe )."

# ╔═╡ e34a8340-3e4c-11eb-3d43-ed3be891a73f
md"#### Conclusion sur l'optimisation de Held Karp"

# ╔═╡ eae5d6e0-3e4c-11eb-3a3e-61b8b965cccd
md"L'algorithme de Held Karp semble donc difficilement améliorable d'un facteur important sans changer entièrement sa conception. Cependant, si nous avions plus de temps nous pourrions suivre 2 chemins pour le rendre plus rapide.
Le premier consiste à repenser entièrement l'implémentation en créant une nouvelle structure de graphe plus légère et spécialement adaptée à Held Karp. 
Le second serait d'exploiter les optimisations de Julia qui semble prendre un temps moins important pour éxecuter 2 fonctions similaires l'une après l'autre et donc il faudrait regrouper l'éxecution des différentes parties de Held Karp."

# ╔═╡ f2424cc0-3e4c-11eb-1373-d5c5664c1818
md"#### Utilisation d'ordinateurs plus puissants"

# ╔═╡ feb82650-3e4c-11eb-3a6c-6f73e71c43e0
md"Une alternative à l'optimisation de Held Karp est d'utiliser des ordinateurs plus puissants pour obtenir un résultat en un temps moindre. Nous nous sommes donc connecté à distance aux machines de l'école, avons installé julia ainsi que toutes les bibliothèques nécessaires et avons testé le temps d'éxecution de Held Karp sur un graphe pour lequel on arrive à avoir rapidement un résultat optimal."

# ╔═╡ 03ffc5f0-3e4d-11eb-20c8-dd186d53a35d
md"Nous avons donc testé l'algortihme de Held Karp sur le graphe gr21 qui nous donne un résultat en 5 secondes au lieu de 10 secondes sur ma machine personnelle, donc un gain de temps de 50%."

# ╔═╡ 093404a0-3e4d-11eb-3f5a-55516758e43e
md"Cependant, une itération de Held Karp prend tout de même encore 60 secondes sur un des graphes proposés pour la phase 5. Il faut donc plus d'une heure pour 100 itérations en théorie et en pratique même après 2h l'algorithme n'a pas effectué 100 itérations (il s'avère après vérifications que le temps d'une itération augmente au fur et à mesure, par exemple l'itération 50 dure plus de 10 minutes). De plus, d'après les résultats de la phase 4, avec notre implémentation, Held Karp semble donner des résultats concluants entre 1000 et 10000 itérations soit entre 16 et 160h d'éxecution sur les machines de l'école en théorie (nombre qui semble devoir être revu à la hausse avec les résultats vus précédemment). Or, on est automatiquement déconnectés des machines de l'école après 8h et nos calculs ont été coupés avant leur finition. Nous n'avons donc pas réussi à lancer une éxecution aussi longue mais d'après les résultats de RSL qui semblaient concluants, avec suffisamment de temps on pourrait avoir une reconstitution parfaite d'une image avec Held Karp. Par ailleurs, avec un nombre trop petit d'itérations, l'algorithme ne donne pas de résultats suffisants pour recréer un tour avec la fonction correct\_one\_tree."

# ╔═╡ 82c30610-3e5a-11eb-36a4-b3d1bb7d2644
md"### FIN" 

# ╔═╡ Cell order:
# ╟─5306c162-03f3-11eb-3b80-3577af92365c
# ╟─74929e92-3d86-11eb-2bef-271e790eab88
# ╟─a2bed920-3d70-11eb-1788-bd5385f4a538
# ╟─a21c5790-3d70-11eb-2004-d970d56eb8b4
# ╟─0e058062-3d7d-11eb-1c2f-35bf63936a6b
# ╟─22c11e60-3d7d-11eb-3143-ad73b73d5a59
# ╟─adfc7870-3d7e-11eb-17c7-d76f7140dd2a
# ╟─863e2a70-3e57-11eb-2bf4-0bbc12618312
# ╟─1a1785b0-1b68-11eb-0070-8b3453a5c896
# ╟─aa712232-3e57-11eb-2355-5710f0658f9f
# ╠═38e5bb30-03f6-11eb-332a-7161bc93b80e
# ╟─84063ae0-1b70-11eb-1407-ff11932e99b6
# ╟─8e12f4c0-3d7f-11eb-2894-13e7ed1985f1
# ╟─9f697ea0-3e57-11eb-0017-13e1d8ba3893
# ╟─cb920f20-3d7f-11eb-3e9a-3384dc2f11db
# ╟─0844bc50-3d81-11eb-0e58-edce2d809d75
# ╠═e779eb3e-3d7f-11eb-3983-379a480d35a9
# ╟─49e6cc70-3d81-11eb-057c-632b5ec8c846
# ╟─bb4dd850-3e57-11eb-029c-cf263fbcd15a
# ╟─d6b19590-3d81-11eb-349f-6bea185c1046
# ╠═2f4763f0-3d83-11eb-19ef-cb3e2696b7a0
# ╟─42928200-3d83-11eb-3bfa-332178fd2405
# ╟─d7451dc0-3e57-11eb-04e7-dde82a1fe8f4
# ╟─d29d4900-3d85-11eb-077b-61cf5ebe96e8
# ╟─c33c8480-3d85-11eb-1b82-31de9c53481f
# ╠═82bd6600-3d84-11eb-167f-47a00a1325a4
# ╟─90c6d7e0-3d84-11eb-302f-2748b11b08fc
# ╟─8ce8c670-3d9c-11eb-1166-9fd188a544ef
# ╠═41345f50-3d88-11eb-27c3-cd012a33c590
# ╟─88413430-3d98-11eb-1da1-cf95185813b4
# ╟─0caa3b80-3d90-11eb-04c2-a32700d33403
# ╟─07c36a70-3d99-11eb-1dc1-cf865d9dde7d
# ╟─0ca83fb0-3d90-11eb-1492-d969b1923c3f
# ╟─0ca5f5c0-3d90-11eb-1036-bf524ca6f20c
# ╟─0ca24c40-3d90-11eb-1afa-99103556f46a
# ╟─0ca02960-3d90-11eb-2bbf-99ab05bf402e
# ╟─c04aaf2e-3d9a-11eb-1016-f354cda5b67c
# ╟─6b9c4240-3d9b-11eb-1176-333e0fce5492
# ╟─c11053b0-3d9b-11eb-21d8-a7d6271cde98
# ╟─b1cf08a0-3d9c-11eb-048a-a7a26b755ca4
# ╟─b27d981e-3d9c-11eb-3968-7b5936c83035
# ╟─5c544b00-3d9d-11eb-330e-5b5d56e81dab
# ╟─51b63eb0-3d9d-11eb-3f9f-bb2ba196a519
# ╟─cf1a28d0-3d9d-11eb-2202-f378bcaf1a18
# ╟─cd7c0930-3d9d-11eb-2326-198d8bf4fbda
# ╟─5d699620-3d9e-11eb-0a05-f9c603ab3a6d
# ╟─6652785e-3d9e-11eb-39a6-1f15754d9664
# ╟─f1cea170-3d9e-11eb-3e52-41511958432e
# ╟─82af7be2-3e4b-11eb-1d4a-c317530fc377
# ╟─895af140-3e4b-11eb-0378-9310f3a64db3
# ╟─8b6455d0-3e4b-11eb-0ed7-d52b1576f65e
# ╟─927802de-3e4b-11eb-0286-f3a7c3f5ed1f
# ╟─18bce000-3e4c-11eb-2746-3f46b5699ed7
# ╟─87986440-3e4c-11eb-0465-89e18c88ed09
# ╠═97cac612-3e4b-11eb-2f90-59e6235e1749
# ╟─142f68a0-3e4c-11eb-1e8f-31845d2ea77e
# ╠═9f7df200-3e4c-11eb-1605-9713851b02f1
# ╟─b235f7d0-3e4c-11eb-0ebf-696aab618714
# ╟─b8a575a0-3e4c-11eb-0836-092cb6f1b34a
# ╟─c3d07fb0-3e4c-11eb-1d1a-7bf2b3eee17d
# ╟─ca669850-3e4c-11eb-16ab-43dde517ae6e
# ╟─d1426c7e-3e4c-11eb-0a83-1db87ffbb917
# ╟─d880fa20-3e4c-11eb-1237-2b1537e7e3b6
# ╟─dcb04bf0-3e4c-11eb-3cf7-d5651761b8fb
# ╟─e34a8340-3e4c-11eb-3d43-ed3be891a73f
# ╟─eae5d6e0-3e4c-11eb-3a3e-61b8b965cccd
# ╟─f2424cc0-3e4c-11eb-1373-d5c5664c1818
# ╟─feb82650-3e4c-11eb-3a6c-6f73e71c43e0
# ╟─03ffc5f0-3e4d-11eb-20c8-dd186d53a35d
# ╟─093404a0-3e4d-11eb-3f5a-55516758e43e
# ╟─82c30610-3e5a-11eb-36a4-b3d1bb7d2644
