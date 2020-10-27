import Base.isless, Base.==
include("../phase1/node.jl")

import Base.show

"""Type représentant les arêtes d'un graphe.

Exemple:

        noeud1 = Node("Kirk", "guitar")
        noeud2 = Node("Lars", 2)
        arete = Edge(50, noeud1, noeud2)

"""
struct Edge
  weight::Float64
  nodes::Tuple{AbstractNode,AbstractNode}
  flag:: Bool
end

function Edge(weight:: Float64, nodes::Tuple{AbstractNode,AbstractNode})
  return(Edge(weight, nodes, false))
end

"""Renvoie le poids de l'arête."""
weight(edge::Edge) = edge.weight

"""Renvoie les noeuds aux extrémités de l'edge."""
nodes(edge::Edge) = edge.nodes

"""Affiche une arête."""
function show(edge::Edge)
  println("Edge weight : ", string(weight(edge)))
  for node in nodes(edge)
    print("  ")
    show(node)
  end
end

"""definit inegalite pour les files """
function isless(p::Edge, q::Edge) 
     return(weight(p) < weight(q))
end

""" definit egalite pour les files"""
function ==(p::Edge, q::Edge) 
    return(weight(p) == weight(q))
end

""" indique si un noeud est dans une arrete ou pas"""
function contains_node(node::AbstractNode, edge:: Edge)
  return(node in nodes(edge))
end