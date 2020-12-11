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
    unshred_min(filename, false, false)
    unshred_mean(filename, false, false)
    unshred_min(filename, false, false)
end 
println("test complete")