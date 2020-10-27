include("connected_component.jl")

"""Algorithme de Kruskal pour calculer un arbre de recouvrement minimal d'un graphe symétrique connexe."""
function find_minimum_spanning_tree(graph::AbstractGraph{T}, verbose::Bool) where T

  # Création une composante connexe pour chaque noeud du graphe
  connected_components = Vector{ConnectedComponent{T}}()
  for node in nodes(graph)
    push!(connected_components, create_connected_component_from_node(node))
  end

  # Ordonnement des liens par poids croissants
  graph_edges = edges(graph)
  sort!(graph_edges, by=e -> e.weight)

  # Pour chaque lien,
  for edge in graph_edges
    if verbose
      print("Searching ")
      show(edge)
    end
    
    # Trouver la ou les composantes connexes y touchant.
    linked_ccs = Vector{ConnectedComponent{T}}()
    for cc in connected_components
      nb_nodes_contained = contains_edge_nodes(cc, edge)

      # Si le lien touche à une seule composante, passer au lien suivant.
      if nb_nodes_contained == 2
        if verbose
          println("Found in " * cc.name * ".")
        end
        break
      elseif nb_nodes_contained == 1
        push!(linked_ccs, cc)
        if length(linked_ccs) == 2
          break
        end
      end
    end

    # Si le lien touche à 2 composantes connexes distinctes, les fusionner
    if length(linked_ccs) == 2
      if verbose
        println("Found between " * linked_ccs[1].name * " and " * linked_ccs[2].name * ". => Merging components.")
      end
      
      sort!(linked_ccs, by=cc -> nb_nodes(cc), rev = true)
      merge_connected_components!(linked_ccs[1], linked_ccs[2], edge)
      deleteat!(connected_components, findall(cc->cc==linked_ccs[2], connected_components))

      # Si nous n'obtenons plus qu'une seule composante connexe, éviter les boucles inutiles
      if length(connected_components) == 1
        break
      end
    end
  end

  # Si le graphe initial n'était pas connexe, choisir la plus grosse composante connexe finale
  if length(connected_components) > 1
    sort!(connected_components, by=cc -> nb_nodes(cc), rev = true)
  end

  return Graph("Minimal spanning tree of " * name(graph), nodes(connected_components[1]), edges(connected_components[1]))
end