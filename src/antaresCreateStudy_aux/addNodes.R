preprocessPlexosData_module = file.path("src", "antaresCreateStudy_aux", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source("parameters.R")

# Ah c'est de tidyr que vient pivot_wider
library(tidyr)

DEFAULT_SCALING_FACTOR = 25
# 
# ✓ Renewables Energy Sources activated
# ✓ Short Term Storages Sources activated
# INFO [2024-08-08 13:57:59] [MAIN] - Creating Etude_sur_R_CSP_sans_batteries__2024_08_08_13_57_59 study...
# 
# INFO [2024-08-08 13:57:59] [MAIN] - Unit commitment mode : FAST
# INFO [2024-08-08 13:57:59] [MAIN] - Adding nodes...
# 
# INFO [2024-08-08 13:58:00] [NODES] - Adding AF-MAR node...
# INFO [2024-08-08 13:58:01] [NODES] - Adding EU-DEU node...
# INFO [2024-08-08 13:58:01] [NODES] - Adding EU-ESP node...
# INFO [2024-08-08 13:58:01] [NODES] - Adding EU-FRA node...
# ERROR [2024-08-08 13:58:01] [WARN] - Could not create node EU-FRA - skipping and continuing...
# INFO [2024-08-08 13:58:01] [MAIN] - Done adding nodes! (run time : 1.78s).
# 
# WHAT IN THE DAMN HELL

# It didn't happen again, maybe a cosmic particle hit my machine at just the wrong time lmao

# ok perhaps an update should be : a "NO_NODE_LEFT_BEHIND" parameter that,
# if checked, shuts down the code whenever a node isn't added
# (so, yknow. what happens when i don't catch the exception actually lmao)
# and also another idea for user transparency : the timer is cool but maybe
# actually do an error counter : whenever we got to the "warn" part of a trycatch
# increment a thing. and then the result will say "got x warnings"
# could even restart it lmao but hm problem of a forever loop

# # Nicolas : BOISSIERE Matteo
# Pour ce problème je dirais que c'est lié au fait qu'Antares fonctionne avec 
# des fichiers et que R ne fait que lire et écrire dans ces fichiers. 
# Mais si l'OS peine à suivre, alors les opérations d'écriture peuvent échouer. 
# 
# Peut-être qu'en insérant un petit Sys.sleep(x) entre chaque création tu 
# auras un comportement plus reproductible. 
# 
# En l"occurence ce n'est pas un problème d'Antares mais de R
#  


getAllNodes <- function() {
  nodes_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    filter(class == "Node") %>%
    mutate(node = tolower(name)) %>%
    select(node)
  
  nodes_lst <- nodes_tbl$node
  return(nodes_lst)
}

# print(getAllNodes())

# generateNodesString <- function(deane_vector) {
#   str <- "c("
#   for (node in deane_vector) {
#     str <- paste0(str, "'", node, "', ")
#   }
#   str <- paste0(str, ")")
#   return(str)
# }

# getNodes, addAttributes, addColor ?

getNodesTable <- function(nodes) {
  nodes_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    filter(class == "Node") %>%
    mutate(
      node = tolower(name),
      continent = tolower(category)) %>%
    select(node, continent) %>%
    filter(node %in% nodes)
  return(nodes_tbl)
}

# print(getNodesTable(europe_nodes_lst))
# print(generateNodesString(getNodesFromContinents("Europe")))

getNodesFromContinents <- function(continents) {
  nodes_tbl <- getTableFromPlexos(PLEXOS_OBJECTS_PATH) %>%
    filter(class == "Node" & category %in% continents) %>%
    mutate(node = tolower(name)) %>%
    select(node)
  
  nodes_lst <- nodes_tbl$node
  return(nodes_lst)
}

# A noter aussi que je pourrais regrouper des districts
# genre, les continents
# ou même, la Chine / les US comme truc unique
# Create a district
# Description
# Allows selecting a set of areas so as to bundle them together in a "district".
# 
# Usage
# createDistrict(
#   name,
#   caption = NULL,
#   comments = NULL,
#   apply_filter = c("none", "add-all", "remove-all"),
#   add_area = NULL,
#   remove_area = NULL,
#   output = FALSE,
#   overwrite = FALSE,
#   opts = antaresRead::simOptions()
# )
# Arguments



# y a-t-il un format d'affectation sur place ? possiblement, à voir
addLatLonToNodes <- function(nodes_tbl) {
  attributes_tbl <- getTableFromPlexos(ATTRIBUTES_PATH) %>%
    filter(class == "Node") %>%
    pivot_wider(names_from = attribute, values_from = value) %>%
    mutate(
      node = tolower(name),
      lat = Latitude,
      lon = Longitude
    ) %>%
    select(node, lat, lon)
  
  nodes_tbl <- nodes_tbl %>%
    left_join(attributes_tbl, by = "node") %>%
    
  
  return(nodes_tbl)
}


addAntaresColorToNodes <- function(nodes_tbl) {
  antaresRed = grDevices::rgb(208, 2, 27, max = 255)
  antaresOrange = grDevices::rgb(230, 108, 44, max = 255)
  antaresYellow = grDevices::rgb(248, 231, 28, max = 255)
  antaresGreen = grDevices::rgb(126, 211, 33, max = 255)
  antaresBlue = grDevices::rgb(74, 144, 226, max = 255)
  antaresFuchsia = grDevices::rgb(189, 16, 224, max = 255)
  
  nodes_tbl <- nodes_tbl %>%
    mutate(antares_color = case_when(
      grepl("africa", continent) ~ antaresOrange,
      grepl("asia", continent) ~ antaresRed,
      grepl("europe", continent) ~ antaresBlue,
      grepl("north america", continent) ~ antaresGreen,
      grepl("oceania", continent) ~ antaresFuchsia,
      grepl("south america", continent) ~ antaresYellow,
      TRUE ~ NA_character_  # There normally shouldn't be any
    )) %>%
    return(nodes_tbl)
}

addVoLLToNodes <- function(nodes_tbl) {
  voll_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(collection == "Regions" & property == "VoLL") %>%
    # NOTA BENE :
    # Je vais faire l'hypothèse que le value of lost load il faut faire x1000
    # parce que des valeurs comme "131" désolé mais je trouve ça tellement peu
    # et c'est vraiment un truc à demander à Deane
    # Quoique non c'est pas fidèle au fait de faire Comme Deane(TM) au début.
    # ....mais bon.....
    mutate(
      continent = tolower(child_object),
      voll = value #* 1000 # Nicolas a dit on évite de multiplier !
    ) %>%
    select(continent, voll)
  
  nodes_tbl <- nodes_tbl %>%
    left_join(voll_tbl, by = "continent")
    return(nodes_tbl)
}

# Eventuellement une facon de séparer les tâches si vraiment on veut :
# # Write some economic options for areas a, b and c
# writeEconomicOptions(data.frame(
#   area = c("a", "b", "c"),
#   dispatchable_hydro_power = c(TRUE, FALSE, FALSE),
#   spread_unsupplied_energy_cost = c(0.03, 0.024, 0.01),
#   average_spilled_energy_cost = c(10, 8, 8),
#   stringsAsFactors = FALSE
# ))

addNodesToAntares <- function(nodes = DEANE_NODES_ALL,
                              add_voll = TRUE,
                              scaling_factor = DEFAULT_SCALING_FACTOR
                              ) {
  nodes_tbl <- getNodesTable(nodes)
  nodes_tbl <- addLatLonToNodes(nodes_tbl)
  nodes_tbl <- addAntaresColorToNodes(nodes_tbl)
  # encore une fois, il y a probablement une méthode "apply" plus rapide
  if (add_voll) {
    nodes_tbl <- addVoLLToNodes(nodes_tbl)
  }
  for (row in 1:nrow(nodes_tbl)) {
    area_name = nodes_tbl$node[row]
    area_lat = nodes_tbl$lat[row]
    area_lon = as.integer(nodes_tbl$lon[row])
    area_color = nodes_tbl$antares_color[row]
    if (add_voll) {
      if (UNIFORM_VOLL) {
        area_voll = 130
        
      } else {
        area_voll = nodes_tbl$voll[row]
      }
    }
    
    x = as.integer(area_lon * scaling_factor)
    y = as.integer(area_lat * scaling_factor)
    
    tryCatch({
      msg = paste("[NODES] - Adding", area_name, "node...")
      logFull(msg)
      if (add_voll) {
        createArea(
          name = area_name,
          color = area_color,
          localization = c(x, y),
          nodalOptimization = nodalOptimizationOptions(average_unsupplied_energy_cost = area_voll)
        )
      } else {
        createArea(
          name = area_name,
          color = area_color,
          localization = c(x, y)
        )
      }
    }, error = function(e) {
      msg = paste("[WARN] - Could not create node", area_name, "- skipping and continuing...")
      logError(msg)
    })
  }
}