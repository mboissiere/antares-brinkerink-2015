preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
source(preprocessPlexosData_module)

source("parameters.R")

# Ah c'est de tidyr que vient pivot_wider
library(tidyr)

DEFAULT_SCALING_FACTOR = 25

getAllNodes <- function() {
  nodes_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Node") %>%
    select(name)
  
  nodes_lst <- nodes_tbl$name
  return(nodes_lst)
}

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
  nodes_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Node") %>%
    rename(
      node = name,
      continent = category) %>%
    select(node, continent) %>%
    filter(node %in% nodes)
  return(nodes_tbl)
}
# print(generateNodesString(getNodesFromContinents("Europe")))

getNodesFromContinents <- function(continents) {
  nodes_tbl <- getTableFromPlexos(OBJECTS_PATH) %>%
    filter(class == "Node" & category %in% continents) %>%
    select(name)
  
  nodes_lst <- nodes_tbl$name
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
    rename(
      node = name,
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
      grepl("Africa", continent) ~ antaresOrange,
      grepl("Asia", continent) ~ antaresRed,
      grepl("Europe", continent) ~ antaresBlue,
      grepl("North America", continent) ~ antaresGreen,
      grepl("Oceania", continent) ~ antaresFuchsia,
      grepl("South America", continent) ~ antaresYellow,
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
      continent = child_object,
      voll = value * 1000
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
    area_lon = nodes_tbl$lon[row]
    area_color = nodes_tbl$antares_color[row]
    if (add_voll) {
      area_voll = nodes_tbl$voll[row]
    }
    
    x = area_lon * scaling_factor
    y = area_lat * scaling_factor
    
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