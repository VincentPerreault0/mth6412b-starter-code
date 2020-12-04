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
""" fonction qui prend en entree le nom d un fichier, decide si on utilise Held et Karp (true) our RSL (false)
et renvoie l'image reconstruite en utilisant le TSP fournit dans instances et les images dechiquetees fournies
en instances"""
function unshred(filename::String, hk::Bool, view::Bool)
    #Step 0: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    if hk #Use Held and Karp alg
        #Step 1: Find minimal tour
        pi_mg = zeros(nb_nodes(graph))
        tree_graph, max_wk = max_w_lk(graph, 0.1 , 100, pi_mg, true, false)
        graphe_tour = get_tour(graph, tree_graph)
        if is_tour(graphe_tour)
        println("tour complete")
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
        #Step1: Find minimal tour 
        tmp=rsl(graph, nodes(graph)[1])
        println("tour complete")
        #Step 3: Find cost of tour
        cost=rsl_graph_weight(graph, tmp)
        println(cost)
        #Step2: Create an array with the order
        liste=Vector{Int64}()
        while length(tmp)>0
            push!(liste, parse(Int64,name(popfirst!(tmp))))
        end
    end 

    #Step 4: Write tour
    tour_name=name(graph)*" tour"
    write_tour(tour_name,liste, cost)

    #Step 5: Reconstruct picture
    picture_name="projet/phase5/images/shuffled/"*name(graph)*".png"
    reconstruct_picture(tour_name, picture_name,"reconstructed "*name(graph)*".png"; view)
end 
