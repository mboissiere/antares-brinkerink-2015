########## IMPORTS ##########

# preprocessPlexosData_module = file.path("src", "data", "preprocessPlexosData.R")
preprocessNinjaData_module = file.path("src", "antaresCreateStudy_aux", "preprocessNinjaData.R")
source(preprocessNinjaData_module)
library(tidyr) 

# print(wind_data_tbl)

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
  
#########

addWindClusters <- function(nodes = all_deane_nodes_lst#,
                               #filter_for_2015 = TRUE
) {
  wind_2015_properties_tbl <- readRDS(wind_2015_properties_path)
  
  wind_cf_ts_tbl <- readRDS(wind_cf_ts_path)
  
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
          cf_ts <- wind_cf_ts_tbl[[generator_name]]/100
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
}