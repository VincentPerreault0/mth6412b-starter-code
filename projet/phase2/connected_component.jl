include("graph.jl")

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