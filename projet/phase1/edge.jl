include("node.jl")
import Base.show
"""Type représentant les arêtes d'un graphe.

Exemple:

        noeud1 = Node("Kirk", "guitar")
        noeud2 = Node("Lars", 2)
        arete = Edge(50, noeud1, noeud2)

"""

# Changements de Edge qui devient mutable

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

"""Affiche une arête."""
function show(edge::Edge)
  println("Edge weight : ", string(weight(edge)))
  for node in nodes(edge)
    print("  ")
    show(node)
  end
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