preprocessPlexosData_module = file.path("src", "antaresCreateStudy_aux", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

# Pour l'instant, copier-coller de addNodes, à modifier

library(tidyr)

# arf, point de vocabulaire :
# dans plexos, node et line
# dans antares, zone/area et link
# ce serait bien d'uniformiser dans l'absolu
getAllLines <- function() {
  lines_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Line") %>%
    # select(parent_object, collection, child_object) %>%
    pivot_wider(names_from = collection, values_from = child_object) %>%
  mutate(
    line = parent_object,
    node_from = tolower(`Node From`),
    node_to = tolower(`Node To`)
    ) %>%
  select(line, node_from, node_to)
  
  return(lines_tbl)
}

getLinesFromNodes <- function(nodes) {
  lines_tbl <- getTableFromPlexos(MEMBERSHIPS_PATH) %>%
    filter(parent_class == "Line") %>%
    select(parent_object, collection, child_object) %>%
    mutate(child_object = tolower(child_object)) %>%
  # print(lines_tbl)
    filter(child_object %in% nodes) %>%
    pivot_wider(names_from = collection, values_from = child_object) %>%
    mutate(
      line = parent_object,
      node_from = tolower(`Node From`),
      node_to = tolower(`Node To`)
    ) %>%
    select(line, node_from, node_to) %>%
    drop_na()
  
  return(lines_tbl)
}

# nodes_test <- c("EU-CHE", "EU-DEU", "EU-FRA")
# nodes_test <- c("EU-FRA", "EU-GBR", "EU-DEU", "EU-ITA", "EU-ESP")
# lines_test <- getLinesFromNodes(nodes_test)
# print(lines_test)

addNTCsToLines <- function(lines_tbl) {
  ntc_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Lines") %>%
    select(child_object, property, value) %>%
    pivot_wider(names_from = property, values_from = value) %>%
    mutate(
      line = child_object,
      direct_ntc = `Max Flow`,
      indirect_ntc = -`Min Flow`
    ) %>%
    select(line, direct_ntc, indirect_ntc)
  
  lines_tbl <- lines_tbl %>%
    left_join(ntc_tbl, by = "line")
  
  return(lines_tbl)
}

lines_tbl <- getAllLines()
lines_tbl <- addNTCsToLines(lines_tbl)
saveRDS(object = lines_tbl, file = ".\\src\\objects\\deane_2015_lines_tbl.rds")

# lines_test <- addNTCsToLines(lines_test)

makeRandomGlobalGrid <- function(nodes) {
  # Sélectionner un élément au hasard
  set.seed(528491)  # Facultatif : pour la reproductibilité
  center_node <- sample(nodes, 1)
  msg = paste("[LINES] - Center node chosen for global grid:", center_node)
  logFull(msg)
  # Extraire le reste de la liste
  other_nodes <- nodes[nodes != center_node]
  
  propertiesLink_lst <- propertiesLinkOptions(transmission_capacities = "infinite")
  
  for (other_node in other_nodes) {
    tryCatch({
      createLink(
      from = center_node,
      to = other_node,
      propertiesLink = propertiesLink_lst
    )
      msg = paste("[LINES] - Adding", center_node, "to", other_node, "line...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Skipping", center_node, "to", other_node, "line (one of the nodes may not exist)")
      logError(msg)
  })
  }
}

# Bon c'est casse pied... Un seul noeud central ça peut créer des congestions à l'heure,
# un full grid ça fait 2 parmi 258 liens ce qui fait 33153 liens (!!!)
#... l'arbre couvrant minimal est le plus legit ?

makeFullGlobalGrid <- function(nodes) {
  propertiesLink_lst <- propertiesLinkOptions(transmission_capacities = "infinite")
  nodes_to_study <- nodes
  
  for (node in nodes_to_study) {
    node_other_nodes <- nodes_to_study[nodes_to_study != node]
    for (node_other_node in node_other_nodes) {
    tryCatch({
      createLink(
        from = node,
        to = node_other_node,
        propertiesLink = propertiesLink_lst
      )
      msg = paste("[LINES] - Adding", node, "to", node_other_node, "line...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Skipping", node, "to", node_other_node, "line (one of the nodes may not exist)")
      logError(msg)
    })
    }
    nodes_to_study  <- nodes_to_study[nodes_to_study != node]
  }
}

makeMinimalGlobalGrid <- function(nodes) {
  source(".\\src\\antaresCreateStudy_aux\\minimumSpanningTree.R")
  propertiesLink_lst <- propertiesLinkOptions(transmission_capacities = "infinite")
  
  # full_edge_tbl <- getMSTedges(nodes)
  full_edge_tbl <- readRDS("~/GitHub/antares-brinkerink-2015/src/objects/deane_global_grid_edges.rds")
  msg = "[LINES] - Computing minimum spanning tree for one world component..."
  logFull(msg)
  for (k in 1:nrow(full_edge_tbl)) {
    current_edge <- full_edge_tbl[k,]
    from_node <- current_edge$node_from
    to_node <- current_edge$node_to
    tryCatch({
      createLink(
        from = from_node,
        to = to_node,
        propertiesLink = propertiesLink_lst
      )
      msg = paste("[LINES] - Adding", from_node, "to", to_node, "line...")
      logFull(msg)
    }, error = function(e) {
      msg = paste("[WARN] - Skipping", from_node, "to", to_node, "line (one of the nodes may not exist)")
      logError(msg)
    })
  }
}

addLinesToAntares <- function(nodes,
                              include_zero_ntc
                              ) {
  tryCatch({
    lines_tbl <- getLinesFromNodes(nodes)
    # print(lines_tbl)
    lines_tbl <- addNTCsToLines(lines_tbl)
    # print(lines_tbl)
    for (row in 1:nrow(lines_tbl)) {
      from_node = lines_tbl$node_from[row]
      to_node = lines_tbl$node_to[row]
      ntc_direct = lines_tbl$direct_ntc[row]
      ntc_indirect = lines_tbl$indirect_ntc[row]
    
      
      if (INFINITE_NTC) {
        propertiesLink_lst <- propertiesLinkOptions(hurdles_cost = INCLUDE_HURDLE_COSTS,
                                                    transmission_capacities = "infinite")
      } else {
        propertiesLink_lst <- propertiesLinkOptions(hurdles_cost = INCLUDE_HURDLE_COSTS,
                                                    transmission_capacities = "enabled")
      }
      
      if (!include_zero_ntc & ntc_direct == 0 & ntc_indirect == 0){
        msg = paste("[LINES] - Skipping", from_node, "to", to_node, "link (zero NTC)")
        logFull(msg)
      } else {
        ts_link <- data.frame(rep(ntc_direct, 8760), rep(ntc_indirect, 8760))
        # Sous-opti car crée de la mémoire (les TS hurdle costs) quand on les utilise pas
        # mais en même temps pour l'instant nous empêche de bug si dataLink_df n'existe pas
        hurdle_cost_direct_ts = rep(HURDLE_COST, 8760)
        hurdle_cost_indirect_ts = rep(HURDLE_COST, 8760)
        impedances_ts = rep(0, 8760)
        loop_flow_ts = rep(0, 8760)
        pst_min_ts = rep(0, 8760)
        pst_max_ts = rep(0, 8760)
        dataLink_df = data.frame(hurdle_cost_direct_ts, hurdle_cost_indirect_ts,
                                 impedances_ts, loop_flow_ts,
                                 pst_min_ts, pst_max_ts)
        
        tryCatch({
          createLink(
            from = from_node,
            to = to_node,
            propertiesLink = propertiesLink_lst,
            tsLink = ts_link,
            dataLink = dataLink_df
          )
          msg = paste("[LINES] - Adding", from_node, "to", to_node, "line...")
          logFull(msg)
        }, error = function(e) {
          msg = paste("[WARN] - Skipping", from_node, "to", to_node, "line (one of the nodes may not exist)")
          logError(msg)
        })
      }
    }
  }, error = function(e) {
    msg = paste("[WARN] - Generation of all lines failed (perhaps there are no connections?), skipping...")
    logError(msg)
  }
  )
  
}