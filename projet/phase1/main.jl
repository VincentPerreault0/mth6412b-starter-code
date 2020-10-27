
include("C:/Users/lora/Desktop/mth6412b-starter-code/projet/phase2/graph.jl")
print("c fait pour include")

file_names = ["C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/bayg29.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/bays29.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/brazil58.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/brg180.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/dantzig42.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/fri26.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/gr17.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/gr21.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/gr24.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/gr48.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/gr120.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/hk48.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/pa561.tsp",
"C:/Users/lora/Desktop/mth6412b-starter-code/instances/stsp/swiss42.tsp"
            ]

for i = 1 : 14
    graph = create_graph_from_stsp_file(file_names[i], true)
    #show(graph)
    println(string("ok file number : ",i))
end
