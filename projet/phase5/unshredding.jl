include("../phase4/held_karp.jl")
include("../phase4/rsl.jl")
include("tools.jl")

""" fonction qui calcule le cout d un tour"""
function tsp_cost(tour::AbstractGraph)
    cost=0
    for edge in edges(tour)
        cost+=weight(edge)
    end
    return(cost)
end 

"""Ne fonctionne pas, a terminer"""
function two_opt(graph::AbstractGraph, q::Vector{Node{T}}, iters_max:: Int64) where T 
    dist=zeros(Float64, 601,601)
    #creation des distances 
    for edge in edges(graph)
        dist[parse(Int64,name(nodes(edge)[1])),parse(Int64,name(nodes(edge)[1]))]=weight(edge)
        dist[parse(Int64,name(nodes(edge)[2])),parse(Int64,name(nodes(edge)[1]))]=weight(edge)
    end 
    list=Dict{Node, Node}
    #z[i,j]=1 si l'arc j est apres i dans le tour 
    z=zeros(Int64, 601,601)
    for i in 1:length(q)-1
        z[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]=1
        list[q[i]]=q[i+1]
    end 
    list[q[length(q)]]=q[1]
    z[parse(Int64,name(q[length(q)])),parse(Int64,name(q[length(1)]))]=1
    
    #Actualisation des arcs a garder 
    iter=0
    better=true
    while iter<iters_max && better 
        better=false 
        for node1 in nodes(graph)
            for node2 in nodes(graph)
                if name(list[node1])!=name(node2) && name(list[node2])!=name(node1) && name(node1)!=name(node2) && dist[parse(Int64,name(node1)),parse(Int64,name(list[node1]))]+dist[parse(Int64,name(node2)),parse(Int64,name(list[node2]))]>dist[parse(Int64,name(node1)),parse(Int64,name(node2))]+dist[parse(Int64,name(list[node1])),parse(Int64,name(list[node2]))]
                    better=true
                    iter+=1
                    z[parse(Int64,name(node1)),parse(Int64,name(list[node1]))]=0
                    z[parse(Int64,name(node2)),parse(Int64,name(list[node2]))]=0
                    z[parse(Int64,name(node1)),parse(Int64,name(node2))]=1
                    z[parse(Int64,name(list[node1])),parse(Int64,name(list[node2]))]=1
                    list[list[node1]]=list[node2]
                    list[node1]=node2
                end
            end
        end
    end  
    println("Fin de 2opt, construction de nouveau tour")
    #Construction de nouveau tour 
    qnew=Vector{typeof(q[1])}()
    #initialisation du nouveau tour
    #de cette maniere le noeud 0 est toujours premier
    push!(qnew, q[1])
    n=list[q[1]]
    #Boucle
    while n!=q[1]
        push!(qnew,n)
        n=list[n]
    end
    return(qnew)
end 

""" fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances."""
function unshred(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 0.1 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        m=0
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            if weight(edge)>m
                m=weight(edge) 
            end
        end
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end

    #Step 4: Write tour
    tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_tour.txt"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new "*name(graph)*".png"; view)
end 

""" fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances. On force le tour de commencer par un des noeuds de l'arc de poids minimal"""
function unshred_min(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 0.1 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        m=0
        mi=1000000
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            if weight(edge)>m
                m=weight(edge) 
            end
            if weight(edge)<mi &&weight(edge)>0
                mi=weight(edge)
                edge_tmp=edge
            end
        end
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        node1=nodes(edge_tmp)[1]
        indice=parse(Int64,name(node1))
        edges(graph)[indice].weight=m+1
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end

    #Step 4: Write tour
    tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_min_tour.txt"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_min "*name(graph)*".png"; view)
end 

"""fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances. On force le tour a commencer qui est le plus loin en moyenne des autres noeuds"""
function unshred_mean(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 0.1 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph
        dict_edges=Dict{Node, Vector{Edge}}()
        for node in nodes(graph)
            dict_edges[node]=Edge[]
        end
        m=0
        mi=1000000
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            push!(dict_edges[nodes(edge)[1]],edge)
            push!(dict_edges[nodes(edge)[2]],edge)
            if weight(edge)>m
                m=weight(edge) 
            end
        end
        arr=Vector{Float64}()
        for node in nodes(graph)
            s=0
            for edge in dict_edges[node]
                s+=weight(edge)
            end 
            s=s/600
            push!(arr, s)
        end 
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        indice=argmax(arr)
        edges(graph)[indice].weight=m+1
        
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end
    #Step 4: Write tour
    tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_mean_tour.txt"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_mean "*name(graph)*".png"; view)
end 

"""fonction qui prend en entree le nom d un fichier, et le nombre d'iterations maximale pour 2_opt, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances. Si on utilise RSL on fait un 2-opt pour ameliorer le tour."""
function unshred_2_opt(filename::String, hk::Bool, view::Bool, max_iters:: Int64)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    
    #Choose algorithm
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 0.1 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        else
            println("Not a tour")
        end
        #Step 2: Create an array with the order
        liste=Vector{Int64}()
        for edge in edges(graphe_tour)
            push!(liste, parse(Int64,name(nodes(edge)[1])))
        end
        #Step 3: Find cost of tour
        cost=tsp_cost(graphe_tour)
    else #use RSL
        #we need to prepare the graph minweights
        m=0
        mi=1000000
        edge_tmp=edges(graph)[1]
        for edge in edges(graph)
            if weight(edge)>m
                m=weight(edge) 
            end
            if weight(edge)<mi
                mi=weight(edge)
                edge_tmp=edge
            end
        end
        #Make sure node minweights are big enough (otherwise Prim will give a false result) 
        for node in nodes(graph)
            node.minweight=m*5
        end
        #modify edge weights for edges from 0
        for edge in edges(graph)[1:length(nodes(graph))-1]
            edge.weight=m+2
        end 
        node1=nodes(edge_tmp)[1]
        indice=parse(Int64,name(node1))
        edges(graph)[indice+1].weight=m+1

        #Step1: Find minimal tour 
        tmp1=rsl(graph, nodes(graph)[1])
        #Step1bis: optimise tour 
        tmp=two_opt(graph, tmp1, max_iters)
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end

    #Step 4: Write tour
    tour_name="projet/phase5/images/solutions/"*name(graph)*"_new_2opt_tour.txt"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"projet/phase5/images/solutions/reconstructed_new_2opt_"*name(graph)*".png"; view)
end 
