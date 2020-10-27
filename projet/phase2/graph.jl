
include("../phase1/node.jl")
include("../phase1/edge.jl")
include("../phase1/read_stsp.jl")

import Base.show

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


"""Affiche un graphe"""
function show(graph::AbstractGraph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
  for node in nodes(graph)
    show(node)
  end
  for edge in edges(graph)
    show(edge)
  end
end

"""Vérifie si le graphe contient un certain noeud."""
function contains_node(graph::AbstractGraph{T}, node::Node{T}) where T
    node in graph.nodes
end

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