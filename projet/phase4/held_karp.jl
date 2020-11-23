include("../phase3/prim.jl")
include("../phase3/priority_queue.jl")
include("../phase2/graph.jl")
include("../phase2/minimum_spanning_tree.jl")
import LinearAlgebra.dot
import LinearAlgebra.norm

"""Creation of subgraph from graph without node s"""
function sub_graph(graph :: AbstractGraph, s :: AbstractNode)
    # On récupère les valeurs nécessaires et on initialise les autres
    g_edges = edges(graph)
    g_nodes = nodes(graph)
    sub_nodes = typeof(s)[]
    sub_edges = Edge[]
    # On récupère tous les sommets sauf celui choisi
    for i = 1 : length(g_nodes)
        if g_nodes[i] != s
            push!(sub_nodes,g_nodes[i])
        end
    end
    # on récupère toutes les arêtes sauf celles contenant le noeud
    for i = 1 : length(g_edges)
        if !(s in(nodes(g_edges[i])))
            push!(sub_edges,g_edges[i])
        end
    end
    return Graph("sub_graph s", sub_nodes, sub_edges)
end

"""Getting the 2 min edges weight in a graph with node s
    needs at least 2 edges connected to s"""
function min_weight_edges(graph :: AbstractGraph, s :: AbstractNode)
    medges = edges(graph)
    edge1 = nothing
    edge2 = nothing
    # On récupère les premières arêtes contenant le noeud s
    for i = 1 : length(medges)
        if (s in(nodes(medges[i]))) && (edge1 === nothing) && (edge2 === nothing) && (nodes(medges[i])[1] != nodes(medges[i])[2])
            edge1 = medges[i]
        elseif (s in(nodes(medges[i]))) && (edge2 === nothing) && (nodes(medges[i])[1] != nodes(medges[i])[2])
            edge2 = medges[i]
        end
    end
    # On parcourt toutes les arêtes reliés à s et on prend celles de poids minimal
    for i = 1 : length(medges)
        if (s in(nodes(medges[i])) && medges[i] != edge1 && medges[i] != edge2 && (nodes(medges[i])[1] != nodes(medges[i])[2]))
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
    node_num = get_node_num(s1)
    if node_num == 0
        set_node_numbers!(graph)
        node_num = get_node_num(s1)
    end
    sgraph = sub_graph(graph,s1)
    mst_prim = prim(sgraph, s2)
    mw_edges = min_weight_edges(graph, s1)
    insert_node!(mst_prim, node_num, s1)
    add_edge!(mst_prim,mw_edges[1])
    add_edge!(mst_prim,mw_edges[2])
    return mst_prim
end

"""Creating min 1-tree from node s1 and prim or kruskal algorithm"""
function min_one_tree(graph :: AbstractGraph, s1 :: AbstractNode, krusk :: Bool, randnode :: Bool)
    # On vérifie que les sommets ont bien un numéro attribué
    node_num = get_node_num(s1)
    if node_num == 0
        set_node_numbers!(graph)
        node_num = get_node_num(s1)
    end
    sgraph = sub_graph(graph,s1)
    # On choisit entre prendre un noeud aléatoire ou le premier noeud
    # ( n'a d'intérêt que pour l'algorithme prim )
    if randnode == true
        # Random node of graph
        max_val = nb_nodes(sgraph)
        node_num = rand(1:max_val)
        node_prim = nodes(sgraph)[node_num]
    else
        # First node of graph
        node_prim = nodes(sgraph)[1]
    end
    # On choisit entre l'algorithme prim et l'algorithme kruskal
    if krusk == true
        # Mst with kruskal
        mst = find_minimum_spanning_tree(sgraph, false)
    else
        # Mst with prim
        mst = prim(sgraph, node_prim)
    end
    # On récupère les min edges et on rajoute le noeud initial
    mw_edges = min_weight_edges(graph, s1)
    insert_node!(mst, node_num, s1)
    add_edge!(mst,mw_edges[1])
    add_edge!(mst,mw_edges[2])
    # L'algorithme de Kruskal renvoyant les noeuds dans le désordre,
    # On les range à nouveau
    if krusk == true
        order_nodes!(mst)
    end
    return mst
end

"""Add pi weight to graph edges"""
function add_pi_graph!(graph::AbstractGraph, pi::Array)
    g_edges = edges(graph)
    old_weights = []
    for i = 1 : length(g_edges)
        edge_n = get_edge_node_nums(g_edges[i])
        # On vérifie que les numéros sont bien attribués aux sommets
        if edge_n[1] == 0
            println("Don't forget to set node numbers")
        end
        # On ajoute les nouvelles valeurs de pi
        push!(old_weights,weight(g_edges[i]))
        new_weight = weight(g_edges[i]) + pi[edge_n[1]] + pi[edge_n[2]]
        set_weight!(g_edges[i], new_weight)
    end
    # On renvoie les anciennes valeurs exactes des poids pour limiter
    # Les erreurs de calcul occasionnées par les effets de bords
    return old_weights
end

"""Substract pi weight to graph edges"""
function sub_pi_graph!(graph::AbstractGraph, old_weights::Array)
    # On récupère les anciennes valeurs de poids données par add_pi_graph
    g_edges = edges(graph)
    for i = 1 : length(g_edges)
        set_weight!(g_edges[i], old_weights[i])
    end
end

"""Checking if a minimum 1-tree is a tour"""
function is_tour(graph :: AbstractGraph)
    otree_degrees = degrees(graph)
    # On vérifie simplement si les degrés sont différents de 2
    for i = 1 : length(otree_degrees)
        if otree_degrees[i] != 2
            return false
        end
    end
    return true
end

"""W function as described in TSP doc"""
function w_one_trees(graph :: AbstractGraph, pi :: Array, krusk :: Bool, randnode :: Bool)
    # On initialise toutes les variables nécessaires
    nb_iterations = nb_nodes(graph)
    g_nodes = nodes(graph)
    node_num = get_node_num(g_nodes[1])
    if node_num == 0
        set_node_numbers!(graph)
    end
    min_wk = nothing
    min_vk = nothing
    min_kth_otree = graph
    old_weights = []
    # On détermine tous 1-tree possibles ( 1 par node )
    for k = 1 : nb_iterations
        # On limite les effets de bords en remettant toutes les
        # valeurs du graphe à 0
        reset_graph!(graph)

        # On ajoute les valeurs de pi au poids des edges
        old_weights = add_pi_graph!(graph,pi)

        # On détermine le 1-tree minimal par rapport au point k
        kth_otree = min_one_tree(graph,g_nodes[k],krusk,randnode)

        # On soustrait les valeurs de pi
        sub_pi_graph!(graph,old_weights)

        # On calcule c_k
        ck = total_weight(kth_otree)

        # On calcule le produit pi.vk       
        sum_pi_vk = 0
        otree_degrees = degrees(kth_otree)
        vk = otree_degrees .- 2
        sum_pi_vk = dot(pi,vk)

        # On obtient la valeur de w pour la k-ieme iteration
        wk = ck + sum_pi_vk

        # On détermine la valeur minimale de wk
        # ( et le vk et kieme 1-tree associé )
        if min_wk === nothing || wk <= min_wk
            min_wk = wk
            min_vk = vk
            #if is_tour(kth_otree)
            #    min_kth_otree = kth_otree
            #end
            #min_kth_otree = kth_otree
        end
        if is_tour(kth_otree)
            min_kth_otree = kth_otree
        end
    end
    # On renvoie le min de wk
    # ( et le vk et kieme 1-tree associé )
    return min_wk, min_vk, min_kth_otree
end

"""Getting the maximum value of w"""
function max_w(graph :: AbstractGraph, tm :: Float64, max_iter :: Int64, pi_m :: Array, krusk :: Bool, randnode :: Bool)
    # On initialise les variables
    iter = 0
    n_tour = 1
    min_tour = graph
    w_ref = 0
    max_wk = 0
    # Dans cette version la limite est un nombre limite d'itérations
    while iter < max_iter
        wk, vk, k_otree = w_one_trees(graph,pi_m,krusk,randnode)
        pi_m = pi_m + tm .* vk
        iter = iter + 1
        if is_tour(k_otree)
            return k_otree, wk
        end
        if wk > max_wk
            max_wk = wk
            #println(wk)
            #println(tm)
            #println(pi_m)
            #println(degrees(k_otree))
            min_tour = k_otree
        end
        #if wk < w_ref
        #    tm = tm / 2
        #elseif wk > w_ref
        #    tm = min(20.0,tm*2)
        #end
        w_ref = wk
        #println(wk)
    end
    return min_tour, max_wk
end

"""Getting the maximum value of w according to LK"""
function max_w_lk(graph :: AbstractGraph, tm :: Float64, max_iter :: Int64, pi_m :: Array, krusk :: Bool, randnode :: Bool)
    
    # On initialise les variables
    iter = 0
    size_g = nb_nodes(graph)
    min_tour = graph
    null_step_size = false
    null_period = false
    null_vk = false
    period = size_g ÷ 2
    period_iter = 0
    w_ref = 0
    vk_ref = []
    first_period = true

    while !null_step_size && !null_period && !null_vk && iter < max_iter     
        
        (wk, vk, k_otree) = w_one_trees(graph,pi_m,krusk,randnode)
        # wk est ici calculé à partir de vk et vk-1
        if iter == 0
            vk_ref = vk
        end
        pi_m = pi_m + tm .*(0.7.*vk+0.3.*vk_ref)
        if is_tour(k_otree)
            println("yesssss")
            min_tour = k_otree
        end
        period_iter = period_iter + 1
        iter = iter + 1

        # End loop update
        if wk > w_ref && period_iter == period 
            period = period*2
            println("coucou3")
            first_period = false
        elseif period_iter == period
            period_iter = 0
            period = period ÷ 2
            tm = tm/2
            println("coucou1")
            first_period = false
        end
        if wk > w_ref && period == size_g ÷ 2 && first_period
            tm = tm*2
            println("coucou2")
        end
        w_ref = wk
        vk_ref = vk

        # End condition update
        null_step_size = (tm < 0.001)
        null_period = (period < 0.001)
        null_vk = (vk == zeros(size_g))

        #println(wk)
    end
    return min_tour
end