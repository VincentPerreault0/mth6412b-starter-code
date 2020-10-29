import Base.show

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
  minweight::Int64
  neighbours::Vector{Node{T}}
end

"""initialise un noeud uniquement avec unnom et un data""" 
function Node(name:: String, data)
  return(Node{typeof(data)}(name, data, 0, nothing, 10000, []))
end

function Node(name:: String, data, rank :: Int64)
 return(Node{typeof(data)}(name, data, rank, nothing, 10000, []))
end

function Node(name:: String, data, parent :: Node)
 return(Node{typeof(data)}(name, data, 0, parent, 10000,[]))
end

# on présume que tous les noeuds dérivant d'AbstractNode
# posséderont des champs `name` et `data`.

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

""" Renvoie la liste des voisin  du noeud"""
function neighbours(node:: AbstractNode)
  return(node.neighbours)
end

""" ajoute un noeud a la liste adjacence de node, sauf s il y est deja"""
function add_neighbour(node::Node{T}, neighbour::Node{T}) where T
  if neighbour in node.neighbours
    return(node)
  end
  push!(node.neighbours, neighbour)
  return(node)
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

"""Affiche un noeud."""
function show(node::AbstractNode)
  println("Node ", name(node), ", data: ", data(node), " rank: ", rank(node), " parent: ", parent(node))
end
