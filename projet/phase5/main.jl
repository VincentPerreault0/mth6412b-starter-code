include("unshredding.jl")

filenames1 = ["instances/stsp/bayg29.tsp",
            "instances/stsp/bays29.tsp",
            "instances/stsp/brazil58.tsp",
            "instances/stsp/dantzig42.tsp",
            "instances/stsp/fri26.tsp",
            "instances/stsp/gr17.tsp",
            "instances/stsp/gr21.tsp",
            "instances/stsp/gr24.tsp",
            "instances/stsp/gr48.tsp",
            "instances/stsp/hk48.tsp",
            "instances/stsp/swiss42.tsp"]

filenames = ["projet/phase5/tsp/instances/abstract-light-painting.tsp"]
filenames_tmp=["projet/phase5/tsp/instances/alaska-railroad.tsp",
            "projet/phase5/tsp/instances/blue-hour-paris.tsp",
            "projet/phase5/tsp/instances/lower-kananaskis-lake.tsp",
            "projet/phase5/tsp/instances/marlet2-radio-board.tsp",
            "projet/phase5/tsp/instances/nikos-cat.tsp",
            "projet/phase5/tsp/instances/pizza-food-wallpaper.tsp",
            "projet/phase5/tsp/instances/the-enchanted-garden.tsp",
            "projet/phase5/tsp/instances/tokyo-skytree-aerial.tsp"]
for filename in filenames
    println("on commence l'image", filename)
    unshred(filename, false, true)
end 
shuffle_picture("projet/phase5/images/original/cubesmall.png","projet/phase5/images/original/cubesmall_shuffled.png",true)

