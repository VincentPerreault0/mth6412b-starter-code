include("../phase4/held_karp.jl")
include("tools.jl")

function unshred(filename::String)
    #Step 1: Create graph 
    graph = create_graph_from_stsp_file(filename, false)

    #Step 2: Find minimal tour using Held and Karp 
    pi_mg = zeros(nb_nodes(graph))
    tree_graph, max_wk = max_w_lk(graph, 1.0, 1000, pi_mg, true, false)
    tour_graph = get_tour(graph, tree_graph)
    show(tour_graph)
end

