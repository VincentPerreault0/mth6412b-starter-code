include("unshredding.jl")
filenames = ["projet/phase5/tsp/instances/abstract-light-painting.tsp",
            "projet/phase5/tsp/instances/alaska-railroad.tsp",
            "projet/phase5/tsp/instances/blue-hour-paris.tsp",
            "projet/phase5/tsp/instances/lower-kananaskis-lake.tsp",
            "projet/phase5/tsp/instances/marlet2-radio-board.tsp",
            "projet/phase5/tsp/instances/nikos-cat.tsp",
            "projet/phase5/tsp/instances/pizza-food-wallpaper.tsp",
            "projet/phase5/tsp/instances/the-enchanted-garden.tsp",
            "projet/phase5/tsp/instances/tokyo-skytree-aerial.tsp"]
for filename in filenames
    println("on commence l'image ", filename)
    unshred(filename, true, false)
    unshred_mean(filename, true, false)
    unshred_min(filename, true, false)
end 
filename="projet/phase5/tsp/instances/abstract-light-painting.tsp"
#println("debut hk normal")
#unshred(filename, true, false)
#println("debut hk mean")
#unshred_mean(filename, true, false)
#println("debut hk mean")
#unshred_min(filename, true, false)
#println("test complete")