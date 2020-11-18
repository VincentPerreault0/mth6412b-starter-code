include("../phase3/prim.jl")
include("../phase3/priority_queue.jl")
include("../phase2/graph.jl")
import LinearAlgebra.dot
import LinearAlgebra.norm

"""Algorithme de création d'un graphe sans le noeud s"""
function sub_graph(graph :: AbstractGraph, s :: AbstractNode)
    g_edges = edges(graph)
    g_nodes = nodes(graph)
    sub_nodes = typeof(s)[]
    sub_edges = Edge[]
    for i = 1 : length(g_nodes)
        if g_nodes[i] != s
            push!(sub_nodes,g_nodes[i])
        end
    end
    for i = 1 : length(g_edges)
        if !(s in(nodes(g_edges[i])))
            push!(sub_edges,g_edges[i])
        end
    end
    return Graph("sub_graph s", sub_nodes, sub_edges)
end

"""Getting the 2 min edges weight in a graph with node s"""
function min_weight_edges(graph :: AbstractGraph, s :: AbstractNode)
    medges = edges(graph)
    edge1 = nothing
    edge2 = nothing
    for i = 1 : length(medges)
        if (s in(nodes(medges[i]))) && (edge1 === nothing) && (edge2 === nothing)
            edge1 = medges[i]
        elseif (s in(nodes(medges[i]))) && (edge2 === nothing)
            edge2 = medges[i]
        end
    end
    for i = 1 : length(medges)
        if (s in(nodes(medges[i])) && medges[i] != edge1 && medges[i] != edge2)
            if (weight(medges[i]) < weight(edge1) || weight(medges[i]) < weight(edge2))
                if weight(edge1) < weight(edge2)
                    edge2 = edge1
                end
                edge1 = medges[i]
            end
        end
    end
    return [edge1,edge2]
end

"""Creating min 1-tree from node s1 and prim algorithm used with s2"""
function min_one_tree_two_nodes(graph :: AbstractGraph, s1 :: AbstractNode, s2 :: AbstractNode)
    sgraph = sub_graph(graph,s1)
    mst_prim = prim(sgraph, s2)
    mw_edges = min_weight_edges(graph, s1)
    add_node!(mst_prim, s1)
    add_edge!(mst_prim,mw_edges[1])
    add_edge!(mst_prim,mw_edges[2])
    return mst_prim
end

"""Creating min 1-tree from node s1 and prim algorithm"""
function min_one_tree(graph :: AbstractGraph, s1 :: AbstractNode)
    sgraph = sub_graph(graph,s1)
    # Random node of graph
    # max_val = nb_nodes(sgraph)
    # node_num = rand(1:max_val)
    # node_prim = nodes(sgraph)[node_num]
    # First node of graph
    node_prim = nodes(sgraph)[1]
    mst_prim = prim(sgraph, node_prim)
    mw_edges = min_weight_edges(graph, s1)
    add_node!(mst_prim, s1)
    add_edge!(mst_prim,mw_edges[1])
    add_edge!(mst_prim,mw_edges[2])
    println("mw_edges : "*string(weight(mw_edges[1])))
    return mst_prim
end

"""W function as described in TSP doc"""
function w_one_trees(graph :: AbstractGraph, pi :: Array)
    set_node_numbers!(graph)
    nb_iterations = nb_nodes(graph)
    g_nodes = nodes(graph)
    min_wk = nothing
    min_vk = nothing
    min_kth_otree = graph
    for k = 1 : nb_iterations
        reset_graph!(graph)
        add_pi_graph!(graph,pi)
        kth_otree = min_one_tree(graph,g_nodes[k])
        ck = total_weight(kth_otree)
        sub_pi_graph!(graph,pi)
        sum_pi_vk = 0
        otree_degrees = degrees(kth_otree)
        vk = otree_degrees .- 2
        #for i = 1 : nb_iterations
        sum_pi_vk = dot(pi,vk)
        println("sum_pi_vk : "*string(sum_pi_vk))
        println("ck : "*string(ck))
        #end
        wk = ck + sum_pi_vk
        if min_wk === nothing || wk <= min_wk
            min_wk = wk
            min_vk = vk
            # A verifier

            min_kth_otree = kth_otree
            
        end
    end
    return min_wk, min_vk, min_kth_otree
end

"""Checking if a minimum 1-tree is a tour"""
function is_tour(graph :: AbstractGraph)
    otree_degrees = degrees(graph)
    for i = 1 : length(otree_degrees)
        if otree_degrees[i] != 2
            return false
        end
    end
    return true
end

"""Getting the maximum value of w"""
function max_w(graph :: AbstractGraph, tm :: Float64, max_iter :: Int64)
    size_g = nb_nodes(graph)
    pi_m = ones(size_g)
    pi_m[1] = 10
    pi_m[2] = 3
    pi_m[3] = 7
    pi_m[5] = 4
    println("pim : ")
    println(pi_m)
    w_val, vk_pi, k_otree = w_one_trees(graph,pi_m)
    println("w_val"*string(w_val))
    println("vk_pi : ")
    println(vk_pi)
    show(k_otree)
    pi_m = pi_m + tm * vk_pi
    w_val_1, vk_pi_1, k_1_otree = w_one_trees(graph,pi_m)
    println("vk_pi_1 : ")
    println(vk_pi_1)
    max_tm = 2*(w_val_1-w_val)/(norm(vk_pi)^2)
    println("max_tm : "*string(max_tm))
    iter = 0
    min_tour = graph
    if is_tour(k_1_otree)
        min_tour = k_1_otree
    end
    while (tm < max_tm) && (iter < max_iter) #&& (w_val_1 > w_val)
        w_val = w_val_1
        vk_pi = vk_pi_1
        println("test : ")
        println(pi_m)
        println(vk_pi)
        pi_m = pi_m + tm .* vk_pi
        w_val_1, vk_pi_1, k_1_otree = w_one_trees(graph,pi_m)
        iter = iter + 1
        println(degrees(k_1_otree))
        if is_tour(k_1_otree)
            min_tour = k_1_otree
            println(" ")
            println("VICTOIRE")
            println(" ")
        end
        println("iter : "*string(iter))
    end
    return min_tour
end

"""Add pi weight to graph edges"""
function add_pi_graph!(graph::AbstractGraph, pi::Array)
    g_edges = edges(graph)
    for i = 1 : length(g_edges)
        edge_n = get_edge_node_nums(g_edges[i])
        if edge_n[1] == 0
            println("Don't forget to set node numbers")
        end
        new_weight = weight(g_edges[i]) + pi[edge_n[1]] + pi[edge_n[2]]
        set_weight!(g_edges[i], new_weight)
    end
end

"""Substract pi weight to graph edges"""
function sub_pi_graph!(graph::AbstractGraph, pi::Array)
    g_edges = edges(graph)
    for i = 1 : length(g_edges)
        edge_n = get_edge_node_nums(g_edges[i])
        if edge_n[1] == 0
            println("Don't forget to set node numbers")
        end
        new_weight = weight(g_edges[i]) - pi[edge_n[1]] - pi[edge_n[2]]
        set_weight!(g_edges[i], new_weight)
    end
end