include("../phase4/held_karp.jl")
include("tools.jl")

function tsp_cost(tour::AbstractGraph)
    cost=0
    for edge in edges(tour)
        cost+=weight(edge)
    end
    return(cost)
end 

function unshred(graph::AbstractGraph)
    #Step 1: Find minimal tour using Held and Karp 
    pi_mg = zeros(nb_nodes(graph))
    tree_graph, max_wk = max_w_lk(graph, 1.0, 1000, pi_mg, true, false)
    graphe_tour = get_tour(graph, tree_graph)
    if is_tour(graphe_tour)
        println("tour complete")
    else
        println("Not a tour")
    end

    #Step 2: Create an array with the order
    liste=Vector{Int64}()
    for edge in edges(graphe_tour)
        push!(liste, data(nodes(edge)[1]))
    end 

    #Step3: Write tour
    cost=tsp_cost(graphe_tour)
    tour_name=name(graph)*" tour"
    write_tour(tour_name,liste, cost)

    #Step4: Reconstruct picture
    filename=name(graph)
    pic=reconstruct_picture(tour_name, filename, "reconstructed "*filename)
    return(pic)
end

function unshred(filename::String)
    #Step 1: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    show(graph)
    #Step2: reconstruct
    return(unshred(graph))
end 
