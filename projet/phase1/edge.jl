import Base.show
include("node.jl")
"""Type représentant les arêtes d'un graphe.

Exemple:

        noeud1 = Node("Kirk", "guitar")
        noeud2 = Node("Lars", 2)
        arete = Edge(50, noeud1, noeud2)

"""
struct Edge
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

"""Affiche une arête."""
function show(edge::Edge)
  println("Edge weight : ", string(weight(edge)))
  for node in nodes(edge)
    print("  ")
    show(node)
  end
end
