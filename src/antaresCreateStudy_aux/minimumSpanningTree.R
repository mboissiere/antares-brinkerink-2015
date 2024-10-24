library(igraph)
library(dplyr)

deane_2015_lines_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_2015_lines_tbl.rds")
deane_all_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_all_nodes_lst.rds")
deane_europe_nodes_lst <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_europe_nodes_lst.rds")

all_nodes <- deane_all_nodes_lst
lines_tbl_short <- deane_2015_lines_tbl %>%
  select(node_from, node_to)

getMSTedges <- function(input_vertices = all_nodes
                        #input_edges = lines_tbl_short
                        ) {
  
  lines_tbl_edges <- getLinesFromNodes(input_vertices) %>%
    select(node_from, node_to)
  
  # Step 1: Convert tibble to an undirected graph
  lines_tbl_edges <- as.data.frame(lines_tbl_edges)
  
  lines_graph <- graph_from_data_frame(lines_tbl_edges, directed = FALSE)
  
  # Step 3: Ensure all nodes (from external list) are in the graph
  # Find nodes in all_nodes that are missing from lines_graph
  missing_nodes <- setdiff(input_vertices, V(lines_graph)$name)
  
  # Add missing (insular) nodes to the graph
  lines_graph <- add_vertices(lines_graph, length(missing_nodes), name = missing_nodes)
  
  # Step 4: Find connected components
  components <- components(lines_graph)
  
  # Step 5: Create a new graph to connect centroids
  # Create a new empty graph for components
  component_graph <- make_empty_graph(directed = FALSE)
  
  # Find centroids of each component (arbitrarily choose a node from each)
  centroids <- sapply(1:length(components$csize), function(i) {
    V(lines_graph)$name[components$membership == i][1]
  })
  
  # Add vertices for centroids to the component graph
  component_graph <- add_vertices(component_graph, length(centroids), name = centroids)
  
  # Add edges between centroids to connect them
  for (i in 1:(length(centroids) - 1)) {
    component_graph <- add_edges(component_graph, c(centroids[i], centroids[i + 1]))
  }
  
  # Step 6: Merge the original graph and component graph using disjoint_union
  full_graph <- disjoint_union(lines_graph, component_graph)
  
  # Step 7: Convert the new full graph to a tibble
  final_edges_tbl <- igraph::as_data_frame(full_graph, what = "edges") %>%
    rename(node_from = from, node_to = to)
  
  final_edges_tbl <- as_tibble(final_edges_tbl)
  
  return(final_edges_tbl)
  
  # Print the resulting tibble
  print(final_edges_tbl, n = 600)
}

# lines_tbl_edges <- as_tibble(lines_tbl_edges)
# print(lines_tbl_edges, n = 600)
# # 
# final_edges_tbl <- getMSTedges()
# print(final_edges_tbl, n = 600)
# final_edges_tbl <- getMSTedges(deane_europe_nodes_lst)
# print(final_edges_tbl, n = 600)
# 
# getLinesFromNodes(deane_europe_nodes_lst)



