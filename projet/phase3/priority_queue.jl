#include("../phase1/edge.jl")
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
function add_item!(q::AbstractQueue{T}, item::T) where T
    if contains_item(q,item)
        return(q)
    end
    push!(q.items, item)
    return(q)
end

"""renvoie le plus petit element de la file"""
function minimum_item(q::AbstractQueue, type ::Type )
    min=items(q)[1]
    if type==Node
        for node in q.items[2:end]
            if minweight(node)<minweight(min)
                min=node
            end
        end
    elseif type==Edge
        for edge in q.items[2:end]
            if weight(edge)<weight(min)
                min=edge
            end
        end
    end
    return(min)
end

"""Retire et renvoie un élément ayant la plus haute priorité.
Ici la priorite est l ordre decroissant. """
function popfirst!(q::PriorityQueue, type::Type)
    highest = minimum_item(q,type)
    idx = findall(x -> x == highest, q.items)[1]
    deleteat!(q.items, idx)
    return(highest)
end

"""Retire et renvoie l'élément ayant la plus haute priorité
 et qui contient le noeud choisit et son parent.
 Si il y a plusieurs edge de meme poids, on choisit celui correspondant
 au noeud choisit."""
function popfirst!(q:: PriorityQueue{Edge}, node:: Node)
    min= minimum_item(q,Edge)
    idx = findall(x -> weight(x) == weight(min), q.items)
    tmp=-1
    for i in idx
        if node in nodes(items(q)[i]) && parent(node) in nodes(items(q)[i])
            tmp=i
            break
        end
    end
    if tmp==-1# si on est la c'est que les edge de poids min ne vont jamais etre utilise
        compteur=0
        for i in idx
            deleteat!(q.items, i-compteur)
            compteur=compteur+1
        end
        return(popfirst!(q, node))#on refait sur la file updatee 
    else
        edge=items(q)[tmp]
        deleteat!(q.items, tmp)
        return(edge)
    end
end