########## IMPORTS ##########

# preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
preprocessNinjaData_module = file.path("src", "antaresCreateStudy_aux", "preprocessNinjaData.R")
source(preprocessNinjaData_module)
# # Hm, mais du coup je les importe ici ou seulement dans mon programme au besoin ?
# # dans le programme peut etre plutot source(importWind)
# # je vois difficilement le generators data y couper en vrai
# # ou alors, preprocessPlexosData dans main,
# # puis, des fonctions ici qui repassent par generators_tbl en argument à chaque fois
# source(preprocessPlexosData_module)
# 
# # En vrai ça pareil, on pourrait ne l'appeler que dans le main, non ? jsp
# source(preprocessNinjaData_module)
library(tidyr) # Is this even useful ? see main


# print(wind_data_tbl)

# Fonction test pour l'instant, le vrai devra de toute façon faire du writeInputTS
# Et on rappelle : un gros "wiki des generateurs" appelé une seule fois, mais qu'on peut amener
# à filter sur les nodes dans le Deane de base donc
getWindPropertiesTable <- function(generators_tbl) {
  wind_generators_tbl <- generators_tbl %>%
    filter(fuel_type == "Wind")
  
  properties_tbl <- getTableFromPlexos(PROPERTIES_PATH) %>%
    filter(property %in% c("Max Capacity", "Units")) %>%
    rename(generator_name = child_object) %>%
    mutate(generator_name = toupper(generator_name)) %>%
    select(generator_name, property, value)
  
  wind_properties_tbl <- wind_generators_tbl %>%
    left_join(properties_tbl, by = "generator_name") %>%
    pivot_wider(names_from = property, values_from = value) 
  
  
  wind_properties_tbl <- wind_properties_tbl %>%
    rename(
      nominal_capacity = "Max Capacity",
      units = Units
    ) %>%
    select(generator_name, node, cluster_type, nominal_capacity, units)
  
  return(wind_properties_tbl)
}
# Est-ce que ce qui est créé en interne par la fonction, est sauvegardé ?
# avec un <- ? avec un = ?
# La réponse est non ! Avec cette structure, wind_generators_tbl n'est pas en mémoire !
# C'est très chouette de rentrer des trucs dans des fonctions en fait au lieu de faire en clair !


# wind_generators_tbl <- getWindPropertiesTable(generators_tbl)
# 
# print(wind_generators_tbl)

#########

addWindClusters <- function(nodes = all_deane_nodes_lst#,
                               #filter_for_2015 = TRUE
) {
  wind_2015_properties_tbl <- readRDS(wind_2015_properties_path)
  # NB : en soi, le test un peu chiant à base de "active_in_2015", ne concerne que le nuc japonais.
  # genre, pour le reste, on pourrait déjà faire le check via commission-date et donc déjà avoir
  # une fonction généralisable à n'importe quelle année (pourvu qu'on ait le load, bien sûr..)
  wind_cf_ts_tbl <- readRDS(wind_cf_ts_path)
  # ACKSHUALLY filter should be applied here. there should be "filter nodes" etc before
  # fusing the Ninja and PLEXOS stuff and keeping NA.
  # else, putting a "node in nodes" here would erase the NA and we would lose juicy data
  # (of course, we want to lose it, but still, the logs are better documentation now.)
  
  # print(solarpv_2015_properties_tbl)
  for (k in 1:nrow(wind_2015_properties_tbl)) {
    row <- wind_2015_properties_tbl[k,]
    # print(row)
    generator_name <- row$generator_name
    if (is.na(row$nominal_capacity)) {
      msg <- paste("[WARN] - Properties for", generator_name, "generator has not been found in PLEXOS data.")
      logError(msg)
    } else {
      node <- row$node
      if (node %in% nodes) {
        active_in_2015 <- row$active_in_2015
        if (!active_in_2015) {
          msg <- paste("[WIND] - Skipped", generator_name, "generator (inactive in 2015).")
          logFull(msg)
        } else {
          nominal_capacity <- row$nominal_capacity
          nb_units <- as.integer(row$nb_units)
          cluster_type <- row$antares_cluster_type
          cf_ts <- wind_cf_ts_tbl[[generator_name]]
          if (is.null(cf_ts)) {
            msg <- paste("[WARN] - Timeseries for", generator_name, "generator has not been found in Ninja data.")
            logError(msg)
          } else {
            tryCatch({
              # msg <- paste("[SOLAR] - Adding", generator_name, "generator to", node, "area...")
              # logFull(msg)
              createClusterRES(
                area = node,
                cluster_name = generator_name,
                group = cluster_type,
                time_series = cf_ts,
                nominalcapacity = nominal_capacity,
                unitcount = nb_units,
                ts_interpretation = "production-factor",
                add_prefix = FALSE
              )
              msg <- paste("[WIND] - Successfully added", generator_name, "generator to", node, "area!")
              logFull(msg)
            }, error = function(e) {
              msg <- paste("[WARN] - Failed to add", generator_name, "to", node, "area, for unknown reasons.")
              logError(msg)
            })
            
          }
        }
        
      }
      
    }
    
  }
}

######


addAggregatedWind <- function(nodes,
                              generators_tbl # Avoir une valeur par défaut ? Pas important ?
                              ) {
  tryCatch({
    # wind_generators_tbl <- getWindPropertiesTable(generators_tbl)
    # # print(wind_generators_tbl)
    # # wind_timeseries_tbl <- getTableFromNinja(WIND_DATA_PATH)
    # # print(wind_timeseries_tbl)
    # # Ah ! Aucun filtrage sur les pays (en vrai c'est normal, du moment qu'en suite 
    # #ça se fait zigouiller dans la mémoire)
    # #gc()
    # # genre comme ça
    # # ou alors, repasser par l'approche où le PATH est en argument
    # # et on ne calcule que wind_timeseries_tbl au sein de aggregateGeneratorTimeSeries
    # wind_aggregated_TS <- aggregateGeneratorTimeSeries(wind_generators_tbl, WIND_DATA_PATH)
    # # print(wind_aggregated_TS)
    # # Une fois qu'on a wind_aggregated_TS bye bye le reste
    # #gc()
    # # Redundant (we could just go through generators_tbl because it's well processed)
    # # but still simplest that comes to mind.
    # # Could probably be refactored with a cool lapply function that would go super fast or something.
    # #nodes = c("EU-CHE", "EU-DEU", "EU-FRA")
    
    
    wind_aggregated_file <- ".\\src\\objects\\wind_2015_aggregated_tbl.rds"
    wind_aggregated_TS <- readRDS(wind_aggregated_file)
    for (node in nodes) {
      wind_ts <- wind_aggregated_TS[[node]]
      tryCatch({
        writeInputTS(
          data = wind_ts,
          type = "wind",
          area = node
        )
        msg = paste("[WIND] - Adding", node, "aggregated wind data...")
        logFull(msg)
      }, error = function(e) {
        msg = paste("[WARN] - Skipped adding wind data for", node, "(no generators found in PLEXOS).")
        logError(msg)
      }
      
      )
    }
    
  }, error = function(e) {
    msg = paste("[WARN] - Skipped adding wind data for all nodes (no generators found in PLEXOS).")
    logError(msg)
  }
  )
  
  # Il y a sûrement une technique de l'infini avec apply qui dézingue tout rapidement
  # mais pour l'instant go faire un vieux for
  # # Filter columns using base R
  # filtered_wind <- wind_data_wide[, nodes, drop = FALSE]
  # # Print the filtered tibble
  # apply(filtered_wind, 1, print)
}

# wind_data_wide est désormais chillax pour faire une fonction "hop là ajouter input ts dans le système"
# à un stade de la fonction on a délaissé les clusters, c'est donc de là que ce distingue je dirais :
# preprocessWindData
# addClusters
# addAggregated
# avec preprocessWindData qui est dans les deux dtf

# Malgré opérations sur tableaux, ne pas oublier de faire des vérifications que y a pas des tableaux vides ou quoi !