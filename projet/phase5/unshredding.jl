include("../phase4/held_karp.jl")
include("tools.jl")

function unshred(filename::String)
    #Step 1: Create graph 
    graph = create_graph_from_stsp_file(filename, false)
    #Step 2: Find minimal tour using Held and Karp 
    pi_mg = zeros(nb_nodes(graph))
    tree_graph, max_wk = max_w_lk(graph, 1.0, 1000, pi_mg, true, false)
    tour = get_tour(graph, tree_graph)
    if is_tour(tour)
        println("Test réussi")
        show(tour)
    else
        println("not a tour")
    end
    #Step 3: Create an array with the order
    liste=Array{Int64}()
    for edge in edges(tour)
        push!(liste, data(nodes(edge)[1]))
    end 
    

end

