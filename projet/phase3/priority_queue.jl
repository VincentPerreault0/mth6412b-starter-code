
include("../phase1/edge.jl")
import Base.minimum
import Base.popfirst!

""" type abstrait de file de priorite"""
abstract type AbstractQueue{T} end

"""Type représentant une file avec des éléments de type T."""
mutable struct Queue{T} <: AbstractQueue{T}
    items::Vector{T}
end

Queue{T}() where T = Queue(T[])

""" Renvoie les elements de la file"""
function items(q::AbstractQueue)
    q.items
end

"""Ajoute `item` à la fin de la file `s`."""
function push!(q::AbstractQueue{T}, item::T) where T
    push!(q.items, item)
    q
end

"""Retire et renvoie l'objet du début de la file."""
popfirst!(q::AbstractQueue) = popfirst!(q.items)

"""Indique si la file est vide."""
function is_empty(q::AbstractQueue)
    length(q.items) == 0
end

"""Donne le nombre d'éléments sur la file."""
function nb_items(q::AbstractQueue)
    return(length(q.items))
end


"""File de priorité (pour les noeuds)"""
mutable struct PriorityQueue{T} <: AbstractQueue{T}
    items::Vector{T}
end

function maximum(q::AbstractQueue)
    return(maximum(items(q)))
end

function PriorityQueue{T}() where T
    PriorityQueue(T[])
end

"""Retire et renvoie l'élément ayant la plus haute priorité."""
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
        println("il y a un probleme avec pop")
    end 
    tmp2=items(q)[tmp]
    deleteat!(q.items, tmp)
    return(tmp2)
end