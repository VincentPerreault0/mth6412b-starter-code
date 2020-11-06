include("../phase3/prim.jl")

function find_children(s:: AbstractNode, dict_edges: Dict{Node, Vector{Edge}}, q:: PriorityQueue)
    print("on est la")
    add_item!(q,s)
    if length(dict_edges[s])==0
       return(q)
    else
        for edge in dict_edges[s]
            for node in nodes(egde)
                if (node==s)==false
                    filter!(x -> x != edge, dict_edges[node])
                end
                q=find_children(node,dict_edges,q)
            end
        end
    end
end

function rsl(graph::AbstractGraph, s::AbstractNode)
    mst=prim(graph,s)
    q=PriorityQueue{Node}()
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
    q=find_children(s,dict_edges,q)
    return(q)
end

    




