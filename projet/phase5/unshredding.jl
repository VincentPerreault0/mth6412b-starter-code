include("../phase4/held_karp.jl")
include("../phase4/rsl.jl")
include("tools.jl")

function tsp_cost(tour::AbstractGraph)
    cost=0
    for edge in edges(tour)
        cost+=weight(edge)
    end
    return(cost)
end 

"""fonction a finir"""
function shred_and_create_new_tsp(filepath::String)
    #Step 1: shuffle picture
    split_filepath = split(filepath, ".")
    split_filename = split_filepath[length(split_filepath)-1]
    filename = String(split_filename)
    filepath_shredded=filename*"_shredded.png"
    shuffle_picture(filepath, filepath_shredded)
    #Step 2: calculate differences between columns 
    picture = load(filepath_shredded)
    nb_row, nb_col = size(picture)
    w = zeros(nb_col, nb_col)
    for j1 = 1 : nb_col
        for j2 = j1 + 1 : nb_col
            w[j1, j2] = compareColumn(picture[:, j1], picture[:, j2])
        end
    end

end

function 2_opt(graph::Abstractgraph, q::Vector{Node{T}}) where T 
    dist=zeros(Float64, 601,601)
    #creation des distances 
    for edge in edges(graph)
        dist[parse(Int64,name(nodes(edge)[1])),parse(Int64,name(nodes(edge)[1]))]=weight(edge)
        dist[parse(Int64,name(nodes(edge)[2])),parse(Int64,name(nodes(edge)[1]))]=weight(edge)
    end 
    #z[i,j]=1 si l'arc (i,j) est dans le tour 
    z=zeros(Int64, 601,601)
    for i in 1:length(q)-1
        z[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]=1
        z[parse(Int64,name(q[i+1])),parse(Int64,name(q[i]))]=1
    end 
    z[parse(Int64,name(q[1])),parse(Int64,name(q[length(q)]))]=1
    z[parse(Int64,name(q[length(q)])),parse(Int64,name(q[length(1)]))]=1
    #Actualisation des arcs a garder 
    x=length(q)
    for i in 1:x
        for j in 1:x
            if 1==1 && j!=1 && j!=2 && j!=x && dist[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]+dist[parse(Int64,name(q[j])),parse(Int64,name(q[j+1]))]>dist[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]+dist[parse(Int64,name(q[i+1])),parse(Int64,name(q[j+1]))]
                z[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]=0
                z[parse(Int64,name(q[j])),parse(Int64,name(q[j+1]))]=0
                z[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]=1
                z[parse(Int64,name(q[i+1])),parse(Int64,name(q[j+1]))]=1
            elseif i==x && j!=x && j!=x-1 &&j!=1 && dist[parse(Int64,name(q[i])),parse(Int64,name(q[1]))]+dist[parse(Int64,name(q[j])),parse(Int64,name(q[j+1]))]>dist[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]+dist[parse(Int64,name(q[1])),parse(Int64,name(q[j+1]))]
                z[parse(Int64,name(q[i])),parse(Int64,name(q[1]))]=0
                z[parse(Int64,name(q[j])),parse(Int64,name(q[j+1]))]=0
                z[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]=1
                z[parse(Int64,name(q[1])),parse(Int64,name(q[j+1]))]=1
            elseif i!=j && (i+1)!=j && (i-1)!=j && dist[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]+dist[parse(Int64,name(q[j])),parse(Int64,name(q[(j+1)%x]))]>dist[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]+dist[parse(Int64,name(q[i+1])),parse(Int64,name(q[(j+1)%x]))]
                z[parse(Int64,name(q[i])),parse(Int64,name(q[i+1]))]=0
                z[parse(Int64,name(q[j])),parse(Int64,name(q[j+1]))]=0
                z[parse(Int64,name(q[i])),parse(Int64,name(q[j]))]=1
                z[parse(Int64,name(q[i+1])),parse(Int64,name(q[(j+1)%x]))]=1
            end
        end
    end 
    #Construction de nouveau tour 
    qnew=Vector{typeof(q[1])}()
    
                
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
    tour_name=name(graph)*"_tour"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"reconstructed "*name(graph)*".png"; view)
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
        edges(graph)[indice+1].weight=m+1
        
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
    tour_name=name(graph)*"_tour"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"reconstructed "*name(graph)*".png"; view)
end 

function unshred_2_opt(filename::String, hk::Bool, view::Bool)
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
    tour_name=name(graph)*"_tour"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"reconstructed "*name(graph)*".png"; view)
end 
