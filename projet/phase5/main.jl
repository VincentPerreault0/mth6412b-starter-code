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

filenames = ["projet/phase5/tsp/instances/abstract-light-painting.tsp",
            "projet/phase5/tsp/instances/alaska-railroad.tsp",
            "projet/phase5/tsp/instances/blue-hour-paris.tsp",
            "projet/phase5/tsp/instances/lower-kananaskis-lake.tsp",
            "projet/phase5/tsp/instances/marlet2-radio-board.tsp",
            "projet/phase5/tsp/instances/nikos-cat.tsp",
            "projet/phase5/tsp/instances/pizza-food-wallpaper.tsp",
            "projet/phase5/tsp/instances/the-enchanted-garden.tsp",
            "projet/phase5/tsp/instances/tokyo-skytree-aerial.tsp"]
#for filename in filenames1
#    println("on commence l'image", filename)
#    unshred(filename)
#end 
node1k=Node("1", 1)
node2k=Node("2", 2)
node3k=Node("3", 3)
node4k=Node("4", 4)
node5k=Node("5", 5)
node6k=Node("6", 6)

edge1k = Edge(2,(node1k,node2k))
edge2k = Edge(5,(node1k,node3k))
edge3k = Edge(3,(node1k,node4k))
edge4k = Edge(3,(node1k,node5k))
edge5k = Edge(7,(node2k,node3k))
edge6k = Edge(1,(node2k,node4k))
edge7k = Edge(5,(node2k,node5k))
edge8k = Edge(8,(node3k,node4k))
edge9k = Edge(2,(node3k,node5k))
edge10k = Edge(1,(node4k,node5k))
edge11k = Edge(8,(node1k,node6k))
edge12k = Edge(5,(node2k,node6k))
edge13k = Edge(2,(node3k,node6k))
edge14k = Edge(4,(node4k,node6k))
edge15k = Edge(9,(node5k,node6k))

graphk = Graph("Graph k", [node1k,node2k,node3k,node4k,node5k,node6k], [edge1k,edge2k,edge3k,edge4k,edge5k,edge6k,edge7k,edge8k,edge9k,edge10k,edge11k,edge12k,edge13k,edge14k,edge15k])
unshred(filenames[1])
shuffle_picture("projet/phase5/images/original/cubesmall.png","projet/phase5/images/original/cubesmall_shuffled.png")
