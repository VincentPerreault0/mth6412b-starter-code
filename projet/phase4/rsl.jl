include("../phase3/prim.jl")

function find_children(s:: Node{T}, dict_edges:: Dict{Node, Vector{Edge}}, q:: Vector{Node{T}}) where T
    show(s)
    push!(q,s)
    if length(dict_edges[s])==0
        return(q)
    else
        for edge in dict_edges[s]
            node1,node2=nodes(edge)
            if (node1==s)==false
                filter!(x -> x != edge, dict_edges[node1])
                q=find_children(node1,dict_edges,q)
            else 
                filter!(x -> x != edge, dict_edges[node2])
                q=find_children(node2,dict_edges,q) 
            end
        end
    end
    return(q)
end

function rsl(graph::AbstractGraph, s::AbstractNode)
    mst=prim(graph,s)
    dict_edges=Dict{Node, Vector{Edge}}()
    for node in nodes(mst)
        dict_edges[node]=Edge[]
    end
    for edge in edges(mst)
        node1=nodes(edge)[1]
        node2=nodes(edge)[2]
        push!(dict_edges[node1],edge)
        push!(dict_edges[node2],edge)
    end
    q=find_children(s,dict_edges,Vector{Node{typeof(s)}}())
    return(q)
end

    




