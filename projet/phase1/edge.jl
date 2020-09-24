
include("node.jl")

import Base.show

"""Type représentant les arêtes d'un graphe.

Exemple:

        noeud1 = Node("Kirk", "guitar")
        noeud2 = Node("Lars", 2)
        arete = Edge("Edgename", noeud1, noeud2)

"""
struct Edge
  name::String
  nodes::Tuple{AbstractNode,AbstractNode}
end

"""Renvoie le nom de l'arête."""
name(edge::Edge) = edge.name

"""Renvoie les noeuds aux extrémités de l'edge."""
nodes(edge::Edge) = edge.nodes

"""Affiche une arête."""
function show(edge::Edge)
  println("Edge ", name(edge))
  for node in nodes(edge)
    show(node)
  end
end