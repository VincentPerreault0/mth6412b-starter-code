### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 76ebe770-01a7-11eb-28ae-a9190e484797
begin
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
	              # Modification du format (k+1, i+k+2) en (k+1, (i+k+2, parse(Float64,data[j+1])))
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
	function read_stsp(filename::String)
	  Base.print("Reading of header : ")
	  header = read_header(filename)
	  println("✓")
	  dim = parse(Int, header["DIMENSION"])
	  edge_weight_format = header["EDGE_WEIGHT_FORMAT"]
	
	  Base.print("Reading of nodes : ")
	  graph_nodes = read_nodes(header, filename)
	  println("✓")
	
	  Base.print("Reading of edges : ")
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
	  println("✓")
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
	  graph_nodes, graph_edges = read_stsp(filename)
	  plot_graph(graph_nodes, graph_edges)
	end
end

# ╔═╡ 030fea20-00b4-11eb-37ed-1b42ab2b64dc
md"# Rapport du projet d'Implémentation d'algo. de rech. opérationnelle"

# ╔═╡ b21a1860-00b4-11eb-059a-e582a4048a0f
md"## Phase 1 : 28/09/2020"

# ╔═╡ c26a45f0-00b4-11eb-2f11-35f6acf05536
md"Antonin Kenens, Vincent Perreault et Laura Kolcheva"

# ╔═╡ 51203c60-01a9-11eb-2d8f-0160d6daf9f7
md"Dépôt Github à l'adresse suivante : https://github.com/AntoninKns/mth6412b-starter-code"

# ╔═╡ cc9740f0-00b4-11eb-0d74-69a99733e847
md"### Question 2"

# ╔═╡ 15556290-00b5-11eb-39a9-7b26085863df
md"Sur le modèle de node.jl, nous avons créé le fichier edge.jl avec une edge de la forme suivante"

# ╔═╡ 2e4fbbb0-00b5-11eb-37db-87b47899920f
abstract type AbstractNode{T} end

# ╔═╡ ad4d6230-00c1-11eb-2b67-2d162e92e486
mutable struct Node{T} <: AbstractNode{T}
  name::String
  data::T
end

# ╔═╡ 67234f60-00b5-11eb-07e9-c3b98a3311a3
struct Edge
  weight::Float64
  nodes::Tuple{AbstractNode,AbstractNode}
end

# ╔═╡ 6ef5dfa0-00b5-11eb-1488-0f4425ec08f2
md"Nous avons ensuite rajouté les fonctions pour obtenir le poids, les nodes et afficher le résultat."

# ╔═╡ c36219f0-01a5-11eb-1a93-fd08057b87ee
md"Voici ci-dessous le code pour l'affichage des nodes, edges et graphs (cf question4)"

# ╔═╡ e04faa50-00b5-11eb-05e8-d7e316d51c93
md"### Question 3"

# ╔═╡ fac6df70-00b5-11eb-3c1c-33518ad54f60
md"Nous avons ensuite modifié le code de Graph.jl pour prendre en compte l'ajout des arêtes"

# ╔═╡ 7bdab130-00c1-11eb-185f-af4454d6d6e5
abstract type AbstractGraph{T} end

# ╔═╡ a7c5fa70-00c1-11eb-2914-335fcc7b996a
mutable struct Graph{T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{T}}
  edges::Vector{Edge}
end

# ╔═╡ bf331640-01a5-11eb-0335-634fdcc83533
begin
	import Base.show
	
	# Affichage des nodes
	name(node::AbstractNode) = node.name
	data(node::AbstractNode) = node.data
	
	function show(node::AbstractNode)
	  println("Node ", name(node), ", data: ", data(node))
	end
	
	# Ajoute des nodes
	function add_node!(graph::Graph{T}, node::Node{T}) where T
  		push!(graph.nodes, node)
  		graph
	end
	
	# Propriétés de edges et affichages des edges"
	weight(edge::Edge) = edge.weight
	nodes(edge::Edge) = edge.nodes

	function show(edge::Edge)
  		println("Edge weights : ", string(weight(edge)))
  		for node in nodes(edge)
    		show(node)
  		end
	end
	
	# Affcihage des graphs
	name(graph::AbstractGraph) = graph.name
	nodes(graph::AbstractGraph) = graph.nodes
	edges(graph::AbstractGraph) = graph.edges
	nb_nodes(graph::AbstractGraph) = length(graph.nodes)
	nb_edges(graph::AbstractGraph) = length(graph.edges)


	function show(graph::Graph)
  		println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", 			nb_edges(graph), " edges.")
  		for node in nodes(graph)
    		show(node)
  		end
  		for edge in edges(graph)
    		show(edge)
  		end
	end
end

# ╔═╡ bebfefb0-00c1-11eb-2d25-e57fc9e4b5b6
md"L'ajout aussi d'une fonction pour ajouter une arête dans le graphe :"

# ╔═╡ 1aebd290-00c2-11eb-3b05-af031ffd1f41
function add_edge!(graph::Graph{T}, edge::Edge) where T
  push!(graph.edges, edge)
  graph
end

# ╔═╡ 1ae61fa2-01a6-11eb-289d-054b239350c6
md"### Question 4"

# ╔═╡ 243d5412-01a6-11eb-1d0d-2d1586931cea
md"Ci-dessus, nous avons modifié le code pour prendre en compte l'affichage des arêtes ainsi que leur poids pour l'affichage des graphes, un exemple d'application est donné ci-dessous :"

# ╔═╡ b01de440-01a6-11eb-39a4-a1f77aea916c
begin
	node1 = Node("Joe", 3.14)
	node2 = Node("Steve", exp(1))
	node3 = Node("Jill", 4.12)
	edge1 = Edge(500, (node1, node2))
	edge2 = Edge(1000, (node2, node3))
	show(edge1)
	show(edge2)
end

# ╔═╡ db3b8ae0-00c2-11eb-1fa0-6d33c1a04106
md"### Question 5"

# ╔═╡ 15a1b000-00c4-11eb-17f9-39a615961dfd
md"Le code de read_stsp a été modifié pour prendre en compte l'affichage des edges comme on peut le voir ci-dessous :"

# ╔═╡ 6f627130-00c2-11eb-1909-45ae8bc4445a
md"### Question 6"

# ╔═╡ 85f7ff50-00c2-11eb-3293-35348983b998
md"Pour finir, nous avons rajouté un programme principal qui se base sur la fonction 'read_stsp' ainsi que les fonction de graph.jl, node.jl et edge.jl pour créer un graph dans le format que nous avons choisi"

# ╔═╡ abeb8fc0-01a7-11eb-229d-853f9c6c72ae
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

# ╔═╡ 29233ffe-00c7-11eb-33ec-4b07ce802efb
md"Un exemple d'utilisation de test sur 'bayg29.tsp' nous donne (une partie a été coupée pour plus de lisbilité) :"

# ╔═╡ 3afca5a0-00c7-11eb-233b-cb6e040352c6
md"Reading of header : ✓

Reading of nodes : ✓

Reading of edges : ✓

Graph Test has 29 nodes and 406 edges.

Node 1, data: [1150.0, 1760.0]

Node 2, data: [630.0, 1660.0]

Node 3, data: [40.0, 2090.0]

Node 4, data: [750.0, 1100.0]

Node 5, data: [750.0, 2030.0]

Node 6, data: [1030.0, 2070.0]

Node 7, data: [1650.0, 650.0]

Edge weights : 97

Node 1, data: [1150.0, 1760.0]

Node 2, data: [630.0, 1660.0]

Edge weights : 205

Node 1, data: [1150.0, 1760.0]

Node 3, data: [40.0, 2090.0]

Edge weights : 139

Node 1, data: [1150.0, 1760.0]

Node 4, data: [750.0, 1100.0]

Edge weights : 86

Node 1, data: [1150.0, 1760.0]

Node 5, data: [750.0, 2030.0]

Edge weights : 60

Node 1, data: [1150.0, 1760.0]

Node 6, data: [1030.0, 2070.0]

Edge weights : 220

Node 1, data: [1150.0, 1760.0]

Node 7, data: [1650.0, 650.0]"

# ╔═╡ f7a2b6e0-00c7-11eb-39ee-abcac8afc248
md"Le test a été fait sur tous les autres graphes donnés et a fonctionné."

# ╔═╡ Cell order:
# ╠═030fea20-00b4-11eb-37ed-1b42ab2b64dc
# ╠═b21a1860-00b4-11eb-059a-e582a4048a0f
# ╠═c26a45f0-00b4-11eb-2f11-35f6acf05536
# ╠═51203c60-01a9-11eb-2d8f-0160d6daf9f7
# ╠═cc9740f0-00b4-11eb-0d74-69a99733e847
# ╠═15556290-00b5-11eb-39a9-7b26085863df
# ╠═2e4fbbb0-00b5-11eb-37db-87b47899920f
# ╠═ad4d6230-00c1-11eb-2b67-2d162e92e486
# ╠═67234f60-00b5-11eb-07e9-c3b98a3311a3
# ╠═6ef5dfa0-00b5-11eb-1488-0f4425ec08f2
# ╠═c36219f0-01a5-11eb-1a93-fd08057b87ee
# ╠═bf331640-01a5-11eb-0335-634fdcc83533
# ╠═e04faa50-00b5-11eb-05e8-d7e316d51c93
# ╠═fac6df70-00b5-11eb-3c1c-33518ad54f60
# ╠═7bdab130-00c1-11eb-185f-af4454d6d6e5
# ╠═a7c5fa70-00c1-11eb-2914-335fcc7b996a
# ╠═bebfefb0-00c1-11eb-2d25-e57fc9e4b5b6
# ╠═1aebd290-00c2-11eb-3b05-af031ffd1f41
# ╠═1ae61fa2-01a6-11eb-289d-054b239350c6
# ╠═243d5412-01a6-11eb-1d0d-2d1586931cea
# ╠═b01de440-01a6-11eb-39a4-a1f77aea916c
# ╠═db3b8ae0-00c2-11eb-1fa0-6d33c1a04106
# ╠═15a1b000-00c4-11eb-17f9-39a615961dfd
# ╠═76ebe770-01a7-11eb-28ae-a9190e484797
# ╠═6f627130-00c2-11eb-1909-45ae8bc4445a
# ╠═85f7ff50-00c2-11eb-3293-35348983b998
# ╠═abeb8fc0-01a7-11eb-229d-853f9c6c72ae
# ╠═29233ffe-00c7-11eb-33ec-4b07ce802efb
# ╠═3afca5a0-00c7-11eb-233b-cb6e040352c6
# ╠═f7a2b6e0-00c7-11eb-39ee-abcac8afc248
