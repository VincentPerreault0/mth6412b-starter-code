
include("../phase1/edge.jl")
import Base.minimum
import Base.popfirst!

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
function push!(q::AbstractQueue{T}, item::T) where T
    push!(q.items, item)
    q
end

"""renvoie le plus petit element de la file
attention les fonctions isless et == doivent etre definies pour le type d objet de items"""
function minimum(q::AbstractQueue)
    return(minimum(items(q)))
end

"""Retire et renvoie un élément ayant la plus haute priorité.
Ici la priorite est l ordre decroissant. 
Attention: les fonctions isless et == doivent etre definies pour le type d objet de items"""
function popfirst!(q::PriorityQueue)
    highest = minimum(items(q))
    idx = findall(x -> x == highest, q.items)[1]
    deleteat!(q.items, idx)
    return(highest)
end

"""Retire et renvoie l'élément ayant la plus haute priorité, et qui contient le noeud concerne et son parent."""
function popfirst!(q:: PriorityQueue{Edge}, node:: Node)
    highest = minimum(items(q))
    idx = findall(x -> x == highest, q.items)
    tmp=-1
    for i in idx
        if node in nodes(items(q)[i]) && parent(node) in nodes(items(q)[i])
            tmp=i
            break
        end
    end
    if tmp==-1
        println("il y a un probleme avec popfirst!")
    end 
    tmp2=items(q)[tmp]
    deleteat!(q.items, tmp)
    return(tmp2)
end